fs = require('fs');
path = require('node:path');

function getBspProject(repoRoot) {
    return path.basename(path.dirname(fs.readlinkSync(repoRoot + '/' + '.bloop')))
};

function getRepoRoot() {
    var match = vscode.window.activeTextEditor?.document.uri.path.match('^(.*/workspace/source-\\d)(/.*)?$')
    return match && match[1];
}

statusBarItem.text = `${vscode.workspace.name}`;
var repoRoot = getRepoRoot();
if (repoRoot) {
    statusBarItem.text += ` | ${path.basename(repoRoot)} [${getBspProject(repoRoot)}]`;
}
