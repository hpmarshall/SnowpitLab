function [cl,sc]=get_snowsymbol_keys(grainstr)
% gets the font keys for SnowSymbolsInt for given
%  string designating grain type

cl=grainstr(1);
switch grainstr
    case '1a'  
        sc='a';
    case '1b'  
        sc='b';
    case '1c'
        sc='c';
    case '1d'
        sc='d';
    case '1e'
        sc='e';
    case '1f'
        sc='f';
    case '1g'
        sc='g';
    case '1h'
        sc='h';
    case '2a'
        sc='i';
    case '2b'
        sc='j'
    case '3a'
        sc='k';
    case '3b'
        sc='l';
    case '3c'
        sc='m';
    case '4a'
        sc='n';
    case '4b'
        sc='o';
    case '4c'
        sc='p'
    case '5a'
        sc='q';
    case '5b'
        sc='r';
    case '5c'
        sc='s';
    case '5d'
        sc='t';
    case '6a'
        sc='u';
    case '6b'
        sc='v';
    case '6c'
        sc='w';
    case '7a'
        sc='x';
    case '7b'
        sc='y';
    case '8a'
        sc='z';
    case '8b'
        sc='A';
    case '8c';
        sc='B';
    case '9a'
        sc='C';
    case '9b'
        sc='D';
    case '9c'
        sc='E';
    case '9d'
        sc='F';
    case '9e'
        sc='G';
end
        

