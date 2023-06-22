import Control.Monad
import Data.Maybe
import Data.List
import XMonad
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Run (spawnPipe)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Grid
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Actions.SpawnOn
import XMonad.Actions.OnScreen
import XMonad.Actions.SwapWorkspaces
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.SetWMName
import System.Exit
import System.IO

-- Default / Grid / Fullscren without borders
myLayouts = Tall 1 (3/100) (55/100) ||| Grid ||| noBorders (fullscreenFull Full)

-- smartBorders removes borders when single window in workspace
noStrutLayout = lessBorders Screen $ myLayouts
strutLessBordersLayout = avoidStruts
  $ lessBorders Screen . avoidStruts
  $ myLayouts

myLayoutHook =
  onWorkspace "1" strutLessBordersLayout
  $ onWorkspace "2" noStrutLayout
  $ onWorkspace "3" noStrutLayout
  $ onWorkspace "4" strutLessBordersLayout
  $ strutLessBordersLayout

myWorkspaces = [ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

myModmask = mod4Mask -- ralt
myTerminal = "alacritty"

-- necessary?
setFullscreenSupported :: X ()
setFullscreenSupported = addSupported ["_NET_WM_STATE", "_NET_WM_STATE_FULLSCREEN"]

addSupported :: [String] -> X ()
addSupported props = withDisplay $ \dpy -> do
    r <- asks theRoot
    a <- getAtom "_NET_SUPPORTED"
    newSupportedList <- mapM (fmap fromIntegral . getAtom) props
    io $ do
      supportedList <- fmap (join . maybeToList) $ getWindowProperty32 dpy a r
      changeProperty32 dpy r a aTOM propModeReplace (nub $ newSupportedList ++ supportedList)


main = do
  xmonad $ docks $ def
    { terminal = myTerminal
    , borderWidth = 4
    , normalBorderColor = "#392b00"
    , focusedBorderColor = "#f0e68c"
    , modMask = myModmask
    , layoutHook = myLayoutHook
    , workspaces = myWorkspaces
    , manageHook = manageDocks <+> manageSpawn
                               <+> (className =? "gnome-mplayer" --> doFullFloat)
                               <+> (isFullscreen --> doFullFloat)
                               <+> fullscreenManageHook
                               <+> manageHook def
    , handleEventHook = handleEventHook def
    , startupHook = do
        setWMName "LG3D" <+> setFullscreenSupported
        spawnOn "1" "firefox"
        spawnOn "2" (myTerminal ++ " --working-directory ~/p/core")
        spawnOn "3" myTerminal
        spawnOn "3" myTerminal
        spawnOn "5" (myTerminal ++ " -e iamb")
        -- sendMessage ToggleStruts -- hide strut on first workspace
        windows (greedyViewOnScreen 1 "4")
    }
    `additionalKeys`
      ([ ((myModmask, xK_p), spawn "dmitri") -- launcher
      -- [ ((myModmask, xK_p), spawn "dmenu_run -fn 'ProFontWindows-12' -sb '#f0e68c' -sf black -nf '#f0e68c' -nb black")
      , ((myModmask .|. shiftMask, xK_m), io (exitWith ExitSuccess)) -- quit?
      , ((myModmask, xK_b), sendMessage ToggleStruts) -- toggle struts (bar)
      , ((myModmask .|. shiftMask, xK_l), spawn "light-locker-command -l")
      ] ++ [((myModmask .|. controlMask, k), windows $ swapWithCurrent i)
          | (i, k) <- zip myWorkspaces [xK_1 ..]]
      )

