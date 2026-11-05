# SellerHelper

A World of Warcraft addon that provides a convenient trading assistant for selling items and auto-purchasing supplies from merchants.

Originally extracted and cleaned up from the BigFoot addon suite's `SellerHelper` module, this standalone version removes all BigFoot dependencies while preserving the full original feature set.

> **`wow-forever` branch**: ported to *World of Warcraft: Forever* (client `_forever_`, product code `wowf`, 1.60.1, `## Interface: 16001`). Removed Classic-only globals are restored by compatibility shims in `BigFootShim.lua` on top of `C_Item`, `C_Container`, `C_MerchantFrame` and `C_AddOns`; gameplay logic is unchanged.

## Features

### Sell Assistant (Tab 1)
- **Bag Scan** — Scans all bags and displays items grouped by quality (Poor → Epic) with icons, stack counts, and sell prices.
- **One-Click Sell** — Click an item name to instantly sell all copies from your bags.
- **Auto-Sell Gray** — Automatically sells all gray (Poor) quality items when opening a merchant window.
- **Auto-Sell List** — Build a custom list of items to auto-sell; drag items in, click to remove.
- **Not-Sell List** — Protect specific gray items (e.g. fishing coins, mining picks) from being auto-sold.
- **Collapsible Headers** — Expand/collapse quality groups for a cleaner view.

### Auto Recharge / Buy Assistant (Tab 2)
- **Auto-Buy List** — Maintain a list of merchant items to automatically purchase.
- **Quantity Control** — Set desired quantities per item with a spinbox (1–9999).
- **Smart Recharge** — On merchant visit, compares what you carry vs. what you want and buys the difference.
- **Add from Merchant** — Click the "+" button on any merchant item to add it to your auto-buy list.

### General
- **Trade Summary** — Reports total income/expense after each merchant or mail session.
- **Persistent Settings** — All preferences saved via `SavedVariables`.
- **Multi-Language** — Supports English, Simplified Chinese (zhCN), and Traditional Chinese (zhTW).

## Slash Commands

| Command | Description |
|---|---|
| `/sh enable` or `/sh on` | Enable the addon |
| `/sh disable` or `/sh off` | Disable the addon |
| `/sh gray` | Toggle auto-sell gray items |
| `/sh announce` | Toggle trade cost announcement |
| `/sh autobuy` | Toggle auto-recharge confirmation |
| `/sh` (no argument) | Show usage help |

`/sellerhelper` works as an alias for `/sh`.

## Installation

1. Download or clone this repository.
2. Copy the entire `SellerHelper-SoD` folder into your WoW addon directory (rename to `SellerHelper` if desired):
   ```
   World of Warcraft\_forever_\Interface\AddOns\SellerHelper\
   ```
3. Enable **SellerHelper** in the in-game AddOns list at the character select screen.

## Compatibility

- **Interface**: 16001 (WoW Forever 1.60.1)
- **Client**: `_forever_` (product code `wowf`), modern Mainline API (12.1.5), Lua 5.1
- **Dependencies**: None

## Architecture

| File | Purpose |
|---|---|
| `SellerHelper.toc` | Addon manifest |
| `BigFootShim.lua` | Lightweight replacements for BigFoot library calls (`BLibrary`, `BigFoot_DelayCall`) plus the WoW Forever shims that restore removed Classic globals (`GetItemInfo`, `GetContainerItemInfo`, `GetContainerNumSlots`, `GetMerchantItemInfo`, ...) |
| `SellerHelperFrame.xml` | UI frame definitions (merchant panel, item lists, tabs) |
| `SellerHelper.lua` | Core sell-assistant logic, bag scanning, auto-sell, not-sell list |
| `AutoRecharge.lua` | Auto-buy / recharge module |
| `enable.lua` | Standalone auto-activation, SavedVariables init, slash commands |

## License

[MIT](LICENSE)
