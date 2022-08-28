const { existsSync, readlinkSync } = require('fs');
const { basename, dirname, join } = require('node:path');
const { spawnSync } = require('node:child_process');

function getBuild(repoRoot) {
    return basename(dirname(readlinkSync(repoRoot + '/' + '.bloop')))
};

function getRepoRoot(path) {
    let match = path.match('^(.*/workspace/source-\\d)(/.*)?$')
    return match && match[1];
}

function getBspStatus(path, repoRoot) {
    log(`Searching for BUILD file for path: ${path}`)
    let dir = getProjectDir(path)
    if (!dir) {
        log(`Warning: no BUILD file for path: ${path}`)
        return '[ No BUILD file ]'
    }
    log(`Found BUILD file at: ${dir}`)

    let relativeDir = dir.replace(new RegExp(`^${repoRoot}/`), '')
    let bloopProject = `${relativeDir}:${basename(dir)}`
    let result = spawnSync('bloop', ['compile', '--no-color', '--config-dir', join(repoRoot, '.bloop'), bloopProject])
    if (result.status == 0) {
        log(`🟢 Compiled bloop project: ${bloopProject}`)
        return '🟢'
    } else {
        let stderr = result.stderr.toString();
        if (stderr.match(new RegExp(`No projects named '${bloopProject}' were found `))) {
            return `[ project not in build: ${bloopProject} ]`
        } else {
            log(`🔴 Error compiling bloop project: ${bloopProject}:\n${indent(stderr)}`)
            return `🔴 ${truncate(stderr, 100, '…')}`
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

function getProjectDir(path) {
    // Return enclosing dir containing BUILD file
    let dir = dirname(path);
    if (existsSync(join(dir, "BUILD")) || existsSync(join(dir, "BUILD.bazel"))) {
        return dir
    } else {
        return getProjectDir(dir)
    }
}

let path = vscode.window.activeTextEditor?.document.uri.path;
let repoRoot = path ? getRepoRoot(path) : null;
if (repoRoot) {
    let checkout = basename(repoRoot)
    let build = getBuild(repoRoot)
    let bspStatus = getBspStatus(path, repoRoot)
    statusBarItem.text = `${checkout} ${build} ${bspStatus}`;
} else {
    statusBarItem.text = `${vscode.workspace.name} [ non-BSP xxxxyyzzz ]`;
}
