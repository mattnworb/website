+++
date = "2012-01-17T00:00:00-00:00"
title = "How to verify a PGP signature with GnuPG"
aliases = [
    "/post/16019918033/how-to-verify-a-pgp-signature-with-gnupg"
]
+++

In case you are an idiot like me, here is a simple set of steps for verifying a PGP signature (for example, if you are downloading [the TrueCrypt installer](http://www.truecrypt.org/downloads) and you want to verify that the binary is intact).

If you already have GnuPG or another PGP client installed, skip steps 1 and 2.

1. Install GnuPG - on my Mac with MacPorts, I ran

    ```
    $ sudo port install gnupg
    ```

2. Create your private key with

    ```
    $ gpg --gen-key
    ```
    
    Accept all of the default options.

3. Download the public key of the person/institution you want to verify. For TrueCrypt, their public key is available [here](http://www.truecrypt.org/downloads2).

4. Import the person’s public key into your key ring with:

    ```
    $ gpg --import TrueCrypt-Foundation-Public-Key.asc
    ```

    (change the filename to whatever is appropriate).

5. You need to sign the person’s public key with your private key, to tell PGP that you “accept” the key. This contains a few steps on it’s own:

  1. List the keys in your keyring with

        ```
        $ gpg --list-keys
        ```

        The output will look like:

        ```
        ... 
        pub   1024D/F0D6B1E0 2004-06-06 uid
                          TrueCrypt Foundation  
        sub   4077g/6B136ECF 2004-06-06 
        ```

  2. The “name” of their key is the part after “1024D/” in the line

        ```
        pub   1024D/F0D6B1E0 2004-06-06
        ```

  3. Sign their public key with:

        ```
        $ gpg --sign-key F0D6B1E0
        ```

6. Now you can verify the signature of the file you downloaded. With TrueCrypt and it’s installer, this command was:

    ```
    $ gpg --verify TrueCrypt\ 7.1\ Mac\ OS\ X.dmg.sig
    ```

    which outputted:

    ```
    gpg: Signature made Thu Sep  1 11:50:54 2011 EDT using DSA key ID F0D6B1E0
    gpg: Good signature from "TrueCrypt Foundation " 
    ```
