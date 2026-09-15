" cyberdream_custom - Custom airline theme for cyberdream colorscheme

let s:theme = 'cyberdream_custom'

function! airline#themes#cyberdream_custom#refresh()

    let bg           = g:palette_bg
    let bg_alt       = g:palette_bg_alt
    let bg_highlight = g:palette_bg_highlight
    let fg           = g:palette_fg
    let grey         = g:palette_grey
    let red          = g:palette_red
    let yellow       = g:palette_yellow

    " =========================================================
    " STATUSLINE
    " =========================================================
    " Placeholder values — will be expanded when the full statusline is customised.

    let N1 = [ fg,   bg_highlight, 255, 238 ]
    let N2 = [ grey, bg_alt,       102, 236 ]
    let N3 = [ grey, bg,           102, 234 ]
    let IA = [ grey, bg,           102, 234 ]
    let ER = [ bg,   red,          234, 203 ]
    let WI = [ bg,   yellow,       234, 227 ]

    let palette = {}

    let palette.normal   = airline#themes#generate_color_map(N1, N2, N3)
    let palette.insert   = palette.normal
    let palette.replace  = palette.normal
    let palette.visual   = palette.normal
    let palette.inactive = airline#themes#generate_color_map(IA, IA, IA)

    let palette.normal.airline_error   = ER
    let palette.normal.airline_warning = WI

    " =========================================================
    " TABLINE
    " =========================================================

    let palette.tabline = {}

    let palette.tabline.airline_tab          = [ grey, bg,           102, 234 ]
    let palette.tabline.airline_tabsel       = [ fg,   bg_highlight, 255, 238 ]
    let palette.tabline.airline_tabmod       = [ grey, bg,           102, 234 ]
    let palette.tabline.airline_tabmod_unsel = [ fg,   bg_highlight, 255, 238 ]
    let palette.tabline.airline_tabtype      = [ grey, bg,           102, 234 ]
    let palette.tabline.airline_tabfill      = [ bg,   bg,           234, 234 ]

    let g:airline#themes#{s:theme}#palette = palette
endfunction

call airline#themes#cyberdream_custom#refresh()
