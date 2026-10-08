on saveAllKeystroke(useAltKey)
  tell application "System Events"
    if useAltKey then
      keystroke "s" using {command down, option down}
    else
      keystroke "s" using {command down}
    end if
  end tell
end saveAllKeystroke

on trySaveBundle(bundleId, useAltKey)
  try
    set appBundle to bundleId as text
    tell application id appBundle
      if not running then
        return
      end if
      activate
    end tell
    delay 0.05
    my saveAllKeystroke(useAltKey)
  end try
end trySaveBundle

on trySaveNamed(appName, useAltKey)
  try
    set appTitle to appName as text
    tell application appTitle
      if not running then
        return
      end if
      activate
    end tell
    delay 0.05
    my saveAllKeystroke(useAltKey)
  end try
end trySaveNamed

on run
  set saveAllOptionS to {"com.microsoft.VSCode", "com.microsoft.VSCodeInsiders", "com.visualstudio.code.oss", "com.vscodium", "com.todesktop.230313mzl4w4u92", "com.codeium.windsurf", "com.exafunction.windsurf", "dev.zed.Zed", "com.sublimetext.4", "com.sublimetext.3", "com.panic.Nova", "com.apple.dt.Xcode", "com.jetbrains.fleet"}
  repeat with bundleId in saveAllOptionS
    trySaveBundle(contents of bundleId, true)
  end repeat

  set saveAllCommandS to {"com.google.android.studio", "com.jetbrains.intellij", "com.jetbrains.intellij.ce", "com.jetbrains.WebStorm", "com.jetbrains.phpstorm", "com.jetbrains.pycharm", "com.jetbrains.pycharm.ce", "com.jetbrains.rubymine", "com.jetbrains.clion", "com.jetbrains.goland", "com.jetbrains.rider", "com.jetbrains.datagrip", "com.jetbrains.aqua", "com.jetbrains.studio", "com.barebones.bbedit", "com.macromates.TextMate", "org.gnu.Emacs", "org.vim.MacVim"}
  repeat with bundleId in saveAllCommandS
    trySaveBundle(contents of bundleId, false)
  end repeat

  set namedOptionS to {"Cursor", "Code", "Visual Studio Code", "VSCodium", "Windsurf", "Zed", "Nova", "Sublime Text", "Xcode", "Fleet"}
  repeat with appName in namedOptionS
    trySaveNamed(contents of appName, true)
  end repeat

  set namedCommandS to {"Android Studio", "IntelliJ IDEA", "PyCharm", "WebStorm", "CLion", "GoLand", "RubyMine", "Rider", "DataGrip", "AppCode", "BBEdit", "TextMate"}
  repeat with appName in namedCommandS
    trySaveNamed(contents of appName, false)
  end repeat
end run
