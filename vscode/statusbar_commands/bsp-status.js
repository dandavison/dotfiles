const { access, readlink } = require('fs/promises');
const { constants, existsSync } = require('fs');
const { basename, dirname, join } = require('node:path');
const { spawn } = require('node:child_process');

async function getBuild(repoRoot) {
    return basename(dirname(await readlink(repoRoot + '/' + '.bloop')))
};

function getRepoRoot(path) {
    let match = path.match('^(.*/workspace/source-\\d)(/.*)?$')
    return match && match[1];
}

async function getBspStatus(path, repoRoot) {
    log(`Searching for BUILD file for path: ${path}`)
    let dir = await getProjectDir(path)
    if (!dir) {
        log(`Warning: no BUILD file for path: ${path}`)
        return '[ No BUILD file ]'
    }
    log(`Found BUILD file at: ${dir}`)

    let relativeDir = dir.replace(new RegExp(`^${repoRoot}/`), '')
    let bloopProject = `${relativeDir}:${basename(dir)}`
    let result = spawn('bloop', ['compile', '--no-color', '--config-dir', join(repoRoot, '.bloop'), bloopProject])
    let stderr = await readAll(result.stderr);
    if (stderr.length == 0) {
        log(`🟢 Compiled bloop project: ${bloopProject}`)
        return '🟢'
    } else {
        log(`stderr: ${stderr}`)
        if (stderr.match(new RegExp(`No projects named '${bloopProject}' were found `))) {
            return `[ project not in build: ${bloopProject} ]`
        } else {
            log(`🔴 Error compiling bloop project: ${bloopProject}:\n${indent(stderr)}`)
            return `🔴 ${stderr.slice(0, 50)}`
        }
    }
}

function indent(s) {
    let pad = '    '
    return pad + s.replaceAll('\n', `\n${pad}`)
}

function truncate(s, n, suffix) {
    if (s.length <= n) {
        return s
    } else if (n <= suffix.length) {
        return suffix
    } else {
        return s.slice(0, n - suffix.length) + suffix
    }
}

async function getProjectDir(path) {
    // Return enclosing dir containing BUILD file
    let dir = dirname(path);
    if (existsSync(join(dir, "BUILD")) || existsSync(join(dir, "BUILD.bazel"))) {
        return dir
    } else {
        return getProjectDir(dir)
    }
}

// TODO
// async function exists(path) {
//     return await access(path, constants.F_OK, (err) => !err)
// }

async function readAll(asyncIter) {
    let data = "";
    for await (const chunk of asyncIter) {
        data += chunk;
    }
    return data
}

statusBarItem.text = '🟠'
let path = vscode.window.activeTextEditor?.document.uri.path;
let repoRoot = path ? getRepoRoot(path) : null;
if (repoRoot) {
    let checkout = basename(repoRoot)
    let build = await getBuild(repoRoot)
    let bspStatus = await getBspStatus(path, repoRoot)
    statusBarItem.text = `${checkout} ${build} ${bspStatus}`;
} else {
    statusBarItem.text = `${vscode.workspace.name} [ non-BSP ]`;
}
