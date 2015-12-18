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

## Options
-a append to output file **(default)**

-o overwrite output file

-t adding timestamp prefix   

## Requirement
Microsoft Windows platforms

## Install
Toe.CMD putting it in your path

## Licence

[MIT](http://opensource.org/licenses/mit-license.php)

## Author

[nmrmsys](https://github.com/nmrmsys)
