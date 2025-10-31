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
                                    inputs ? [ ] ,
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
                                                                        application_ =
                                                                            writeShellApplication
                                                                                {
                                                                                    name = name ;
                                                                                    runtimeInputs = [ ] ;
                                                                                    text =
                                                                                        ''
                                                                                            ${ builtins.concatStringsSep "" ( builtins.map ( input : builtins.concatStringsSep "" [ "V" ( builtins.hashString "sha512" input ) "=" input ] ) inputs ) }
                                                                                            ${ builtins.concatStringsSep "" ( builtins.map ( input : "PATH=$PATH:$V${ builtins.hashString "sha512" input }" inputs ) ) }
                                                                                            ${ writeShellApplication { name = name ; text = text ; } }/bin/${ name }
                                                                                        '' ;
                                                                                } ;
                                                                        in
                                                                            ''
                                                                                mkdir --parents /mount/bin
                                                                                ln --symbolic ${ application }/bin /mount/bin
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        targets = [ "bin" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {
                                            expected ,
                                            inputs ? [ ] ,
                                            mkDerivation ,
                                            name ,
                                            text
                                        } :
                                            mkDerivation
                                                {
                                                    installPhase = ''execute-test "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                writeShellApplication
                                                                    {
                                                                        name = "execute-test" ;
                                                                        runtimeInputs = [ coreutils ( failure "99987644" ) ] ;
                                                                        text =
                                                                            let
                                                                                instance = implementation { inputs = inputs ; name = name ; text = text ; } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "init" "targets" ] != builtins.attrNames instance then ''failure instance "${ builtins.toJSON ( builtins.attrNames instance ) }"'' else "#" }
                                                                                        ${ if expected != builtins.toString init then ''failure init "${ builtins.toString init }"'' else "#" }
                                                                                        ${ if [ "bin" ] != instance.targets then ''failure targets "${ builtins.toJSON ( instance.targets ) }"'' else "#" }
                                                                                    '' ;
                                                                    }
                                                            )
                                                        ] ;
                                                    src = ./. ;
                                                } ;
                                    implementation = implementation ;
                                } ;
            } ;
}