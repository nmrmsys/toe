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
�E�R�}���h�W�����͂ւ̉�� toe test.log / cmd �Ōł܂�
�E�����t�@�C���Ή��Ƃ�
�E���s���ԎZ�o
�E�o�̓I�v�V�����̊g��

*/

//javascript�œ��t�t�H�[�}�b�^ http://qiita.com/egnr-in-6matroom/items/37e65bb642d2e158804c
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

//�ϐ���`
var sMode = 'tee', sFileName = '', sCommand = '';
var bOptA = true, bOptO = false, bOptT = false;

with(WScript){

    //�������
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
    
    //�O���I�u�W�F�N�g�擾
    var oFSO   = new ActiveXObject("Scripting.FileSystemObject");
    var oShell = new ActiveXObject("WScript.Shell");
    
    //���͐ݒ�
    var oInput, oExec;
    if(sMode == 'tee'){
        oInput = oFSO.GetStandardStream(0); //�W������
    } else {
        oExec  = oShell.Exec(sCommand);
        oInput = oExec.StdOut;
    }
    
    //�o�͐ݒ�
    var nIoMode  = bOptO ? 2 : 8; // overwrite : append
    var oOutFile = oFSO.OpenTextFile(sFileName, nIoMode, true); //�w�胂�[�h�A�V�K�t�@�C�����쐬
    var oStdOut  = oFSO.GetStandardStream(1); //�W���o��
    
    //�J�n�^�C���X�^���v�o��
    if(bOptT){
        var sTimeStamp = 'START: ' + dateFormat.format(new Date(), 'yyyy/MM/dd hh:mm:ss');
        oOutFile.WriteLine(sTimeStamp);
        oStdOut.WriteLine(sTimeStamp);
    }
    
    //�R�}���h���C���o��
    if(sCommand != ''){
        oOutFile.WriteLine('>' + sCommand);
        oStdOut.WriteLine('>' + sCommand);
    }
    
    //���͂��I���܂�1�����Âo��
    while(!oInput.AtEndOfStream){
        var Char = oInput.Read(1);
        oOutFile.Write(Char);
        oStdOut.Write(Char);
    }
    
    //�I���^�C���X�^���v�o��
    if(bOptT){
        var sTimeStamp = 'END: ' + dateFormat.format(new Date(), 'yyyy/MM/dd hh:mm:ss');
        oOutFile.WriteLine(sTimeStamp);
        oStdOut.WriteLine(sTimeStamp);
    }
    
    //�ǋL���͏o�̓t�@�C�������ɉ��s�t��
    if(bOptA)
        oOutFile.WriteLine();
    
    //�I������
    oOutFile.Close();
    oStdOut.Close();
    
    if(sMode == 'tee'){
        Quit(0);
    } else {
        Quit(oExec.ExitCode);
    }
    
}

//�������
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

//�g�p�@�\��
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

//�G���[�\��
function showError(errMsg) {
    
    with(WScript){
        Echo('toe: ' + errMsg);
        Quit(-1);
    }
    
}