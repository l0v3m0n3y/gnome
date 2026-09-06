# gnome
web api for gnome.org GNOME is a desktop environment and suite of software for Linux and BSD developed by the GNOME Project and released as free and open source software.
# main
```swift
import Foundation
import gnome

let gnomeCli = GnomeSite()
let langs = try await gnomeCli.getSupportedLanguages()
print(langs)
```

# Launch (your script)
```
swift run
```
