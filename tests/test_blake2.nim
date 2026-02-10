import unittest
import strutils
import ../blake2

proc hex2str(s: string): string =
  result = ""
  for i in countup(0, high(s), 2):
    if i + 1 <= high(s):
      add(result, chr(parseHexInt(s[i] & s[i+1])))

suite "BLAKE2b Tests":
  test "Basic hash tests":
    check:
      getBlake2b("abc", 4, "abc") == "b8f97209"
      getBlake2b("", 4, "abc")    == "8ef2d47e"
      getBlake2b("abc", 4)        == "63906248"
      getBlake2b("", 4)           == "1271cf25"

  test "Incremental hashing consistency":
    var b1, b2: Blake2b
    blake2b_init(b1, 4)
    blake2b_init(b2, 4)
    
    # Update b1 byte by byte
    blake2b_update(b1, 97'u8, 1)
    blake2b_update(b1, 98'u8, 1)
    blake2b_update(b1, 99'u8, 1)
    
    # Update b2 with all bytes at once
    blake2b_update(b2, @[97'u8, 98'u8, 99'u8], 3)
    
    check:
      $blake2b_final(b1) == $blake2b_final(b2)

  test "Known answer tests from blake2b-kat.txt":
    let f = open("tests/testdata/blake2b-kat.txt", fmRead)
    var
      data, key, hash, r: string
      b: Blake2b
    
    try:
      while true:
        data = f.readLine()
        if data.len > 4:
          data = hex2str(data[4..data.high])
        else:
          data = ""
        
        key = f.readLine()
        if key.len > 5:
          key = hex2str(key[5..key.high])
        else:
          key = ""
        
        hash = f.readLine()
        if hash.len > 6:
          hash = hash[6..hash.high]
        else:
          hash = ""
        
        # Test direct hashing
        r = getBlake2b(data, 64, key)
        check:
          r == hash
        
        # Test incremental hashing
        blake2b_init(b, 64, cstring(key), 64)
        for i in 0..high(data):
          blake2b_update(b, ($data[i]).cstring, 1)
        check:
          $blake2b_final(b) == hash
        
        discard f.readLine()
    except IOError:
      discard
    finally:
      close(f)