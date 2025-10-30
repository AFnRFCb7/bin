{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        coreutils ,
                        writeShellApplication
                    } :
                        let
                            implementation =
                                {
                                    inputs ,
                                    name ,
                                    text
                                } :
                                    {
                                        init =
                                            { resources , self } :
                                                let
                                                    application =
                                                        writeShellApplication
                                                            {
                                                                name = "init" ;
                                                                runtimeInputs = [ coreutils ] ;
                                                                text =
                                                                    let
                                                                        application__ =
                                                                            writeShellApplication
                                                                                {
                                                                                    name = name ;
                                                                                    runtimeInputs = [ ] ;
                                                                                    text = text ;

                                                                                } ;
                                                                        application_ =
                                                                            writeShellApplication
                                                                                {
                                                                                    name = name ;
                                                                                    runtimeInputs = [ ] ;
                                                                                    text =
                                                                                        ''
                                                                                            ${ builtins.concatStringsSep "" ( builtins.map ( input : builtins.concatStringsSep "" [ "V" ( builtins.hashString "sha512" input ) "=" input ] ) inputs ) }
                                                                                            ${ builtins.concatStringsSep "" ( builtins.map ( input : "PATH=$PATH:$V${ builtins.hashString "sha512" input }" inputs )
                                                                                            ${ application__ }
                                                                                        '' ;
                                                                                } ;
                                                                        in
                                                                            ''
                                                                                mkdir --parents /mount/bin
                                                                                cp ${ pkgs.writeShellApplication
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        targets = [ "bin" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {

                                        } ;
                                    implementation = implementation ;
                                } ;
            } ;
}