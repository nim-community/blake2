# Blake2
![workflow status](https://github.com/nim-community/blake2/workflows/test/badge.svg)

[BLAKE2b](https://blake2.net) cryptographic hash function for Nim.

```nim
import blake2

# Simple hashing
echo getBlake2b("data", 32)

# With key
var b: Blake2b
blake2b_init(b, 4, "key", 3)
blake2b_update(b, "data", 4)
assert($blake2b_final(b) == getBlake2b("data", 4, "key"))
```

Run tests: `nimble test`

License: CC0 1.0 Universal (see LICENSE file)

