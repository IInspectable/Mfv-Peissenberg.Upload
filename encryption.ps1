function CreateAesObject($key, $IV) {

    $aesManaged =[System.Security.Cryptography.Aes]::Create()
    # $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    # $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    # $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    # $aesManaged.BlockSize = 128
    # $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function CreateAesKey() {
    $aesManaged = CreateAesObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function EncryptAesString($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = CreateAesObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function DecryptAesString($key, $encryptedStringWithIV) {

    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = CreateAesObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()

    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}