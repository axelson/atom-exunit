# Atom ExUnit Runner Package

[![ghit.me](https://ghit.me/badge.svg?repo=axelson/atom-exunit)](https://ghit.me/repo/axelson/atom-exunit)

Add ability to run ExUnit and see the output without leaving Atom.

HotKeys:

- __Ctrl+Alt+T__ - executes all tests the current file
- __Ctrl+Alt+X__ - executes only the test on the line the cursor's at
- __Ctrl+Alt+E__ - re-executes the last executed test

<!-- TODO: Add screenshot -->
<!-- ![Screenshot](http://cl.ly/image/2G2B3M2g3l3k/stats_collector_spec.rb%20-%20-Users-fcoury-Projects-crm_bliss.png) -->

## Configuration

By default this package will run `exunit` as the command.

You can set the default command by either accessing the Settings page (Cmd+,)
and changing the command option.

<!-- TODO: Add screenshot -->
<!-- ![Configuration Screenshot](http://f.cl.ly/items/2k1C0E0e1l2Z3m1l3e1R/Settings%20-%20-Users-fcoury-Projects-crm_bliss.jpg) -->

Or by opening your configuration file (clicking __Atom__ > __Open Your Config__)
and adding or changing the following snippet:

    'exunit':
      'command': 'exunit'

## Acknowledgements

This is a direct fork of atom-rspec (https://github.com/fcoury/atom-rspec). Thanks for @fcoury for the code!
