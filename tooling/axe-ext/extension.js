const vscode = require('vscode');
const { LanguageClient, TransportKind } = require('vscode-languageclient/node');

let client;

function activate(context) {
    const config = vscode.workspace.getConfiguration('axe.lsp');
    let serverPath = config.get('serverPath', '');
    
    if (!serverPath) {
        serverPath = process.platform === 'win32' ? 'axels.exe' : 'axels';
    }
    
    const serverOptions = {
        run: {
            command: serverPath,
            transport: TransportKind.stdio
        },
        debug: {
            command: serverPath,
            transport: TransportKind.stdio
        }
    };
    
    const clientOptions = {
        documentSelector: [
            { scheme: 'file', language: 'axe' }
        ],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher('**/.{axe,axec}')
        }
    };
    
    client = new LanguageClient(
        'axeLSP',
        'Axe Language Server',
        serverOptions,
        clientOptions
    );
    
    client.start();
    
    console.log('Axe Language Server activated');
}

function deactivate() {
    if (!client) {
        return undefined;
    }
    return client.stop();
}

module.exports = {
    activate,
    deactivate
};
