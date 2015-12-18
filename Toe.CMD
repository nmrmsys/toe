@if(0)==(0) ECHO OFF
CScript.exe //NoLogo //E:JScript "%~f0" %*
GOTO :EOF
@end
/*

Toe - Tee on Execute
====
command line stiring and execution result to output file and standard output

## Usage
Form1: toe [output file] <toe options> / [command] <options>

    > toe test.log / test.bat -foo /bar baz

output result (output file and standard output)

    > test.bat -foo /bar baz
    test1 test1 test1
    test2 test2 test2
    test3 test3 test3

toe return [exit code] is command [exit code] 

Form2: [command] <options> | toe [output file] <toe options> **# tee compatible**  

    > test.bat -foo /bar baz | toe test.log

TODO:
・コマンド標準入力への介入 toe test.log / cmd で固まる
・複数ファイル対応とか
・実行時間算出
・出力オプションの拡張

*/

//javascriptで日付フォーマッタ http://qiita.com/egnr-in-6matroom/items/37e65bb642d2e158804c
dateFormat = {
  fmt : {
    "yyyy": function(date) { return date.getFullYear() + ''; },
    "MM": function(date) { return ('0' + (date.getMonth() + 1)).slice(-2); },
    "dd": function(date) { return ('0' + date.getDate()).slice(-2); },
    "hh": function(date) { return ('0' + date.getHours()).slice(-2); },
    "mm": function(date) { return ('0' + date.getMinutes()).slice(-2); },
    "ss": function(date) { return ('0' + date.getSeconds()).slice(-2); }
  },
  format:function dateFormat (date, format) {
    var result = format;
    for (var key in this.fmt)
      result = result.replace(key, this.fmt[key](date));
    return result;
  }
};

//変数定義
var sMode = 'tee', sFileName = '', sCommand = '';
var bOptA = true, bOptO = false, bOptT = false;

with(WScript){

    //引数解析
    if(!getOpts(Arguments)){
        showUsage();
    }
    
/*
    Echo('sMode: ' + sMode);
    Echo('sFileName: ' + sFileName);
    Echo('sCommand: ' + sCommand);
    Echo('bOptA: ' + bOptA);
    Echo('bOptO: ' + bOptO);
    Echo('bOptT: ' + bOptT);
*/
    
    //外部オブジェクト取得
    var oFSO   = new ActiveXObject("Scripting.FileSystemObject");
    var oShell = new ActiveXObject("WScript.Shell");
    
    //入力設定
    var oInput, oExec;
    if(sMode == 'tee'){
        oInput = oFSO.GetStandardStream(0); //標準入力
    } else {
        oExec  = oShell.Exec(sCommand);
        oInput = oExec.StdOut;
    }
    
    //出力設定
    var nIoMode  = bOptO ? 2 : 8; // overwrite : append
    var oOutFile = oFSO.OpenTextFile(sFileName, nIoMode, true); //指定モード、新規ファイルを作成
    var oStdOut  = oFSO.GetStandardStream(1); //標準出力
    
    //開始タイムスタンプ出力
    if(bOptT){
        var sTimeStamp = 'START: ' + dateFormat.format(new Date(), 'yyyy/MM/dd hh:mm:ss');
        oOutFile.WriteLine(sTimeStamp);
        oStdOut.WriteLine(sTimeStamp);
    }
    
    //コマンドライン出力
    if(sCommand != ''){
        oOutFile.WriteLine('>' + sCommand);
        oStdOut.WriteLine('>' + sCommand);
    }
    
    //入力が終わるまで1文字づつ出力
    while(!oInput.AtEndOfStream){
        var Char = oInput.Read(1);
        oOutFile.Write(Char);
        oStdOut.Write(Char);
    }
    
    //終了タイムスタンプ出力
    if(bOptT){
        var sTimeStamp = 'END: ' + dateFormat.format(new Date(), 'yyyy/MM/dd hh:mm:ss');
        oOutFile.WriteLine(sTimeStamp);
        oStdOut.WriteLine(sTimeStamp);
    }
    
    //追記時は出力ファイル末尾に改行付加
    if(bOptA)
        oOutFile.WriteLine();
    
    //終了処理
    oOutFile.Close();
    oStdOut.Close();
    
    if(sMode == 'tee'){
        Quit(0);
    } else {
        Quit(oExec.ExitCode);
    }
    
}

//引数解析
function getOpts(args){
    
    if(args.length == 0)
        return false;
    
    for(var i = 0; i < args.length; i++){
        //WScript.Echo(args(i));
        if(sMode == 'tee'){
            switch(args(i).toLowerCase()){
                case '/':
                    sMode = 'toe';
                    break;
                case '-h': case '/h':
                    return false;
                case '-a': case '/a':
                    break;
                case '-o': case '/o':
                    bOptO = true;
                    bOptA = false;
                    break;
                case '-t': case '/t':
                    bOptT = true;
                    break;
                default:
                    var sArg1 = args(i).substr(0,1);
                    if(sArg1 == '/' || sArg1 == '-'){
                        showError('Invalid switch ' + args(i));
                    }
                    sFileName = args(i); 
            }
        } else {
            sCommand = sCommand + args(i) + ' ';
        }
    }
    
    if(sFileName == '')
        showError('[output file] is not specified');
    
    if(sMode == 'toe' && sCommand == '')
        showError('[command] is not specified');
    
    return true;
}

//使用法表示
function showUsage() {
    
    with(WScript){
        Echo('Usage: toe [output file] / [command] or [command] | toe [output file]');
        Echo('');
        Echo('Options:');
        Echo('  -a append to output file (default)');
        Echo('  -o overwrite output file');
        Echo('  -t adding timestamp prefi');
        Quit(0);
    }
    
}

//エラー表示
function showError(errMsg) {
    
    with(WScript){
        Echo('toe: ' + errMsg);
        Quit(-1);
    }
    
}
