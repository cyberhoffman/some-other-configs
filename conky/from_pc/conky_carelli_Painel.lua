require 'cairo'

-- Converte o ângulo de graus para radianos
-- E corrige o ângulo inicial do arco (-90º)
function angulo( graus )
    radianos = (graus - 90) * (math.pi/180)
    return radianos
end

function rgb( r, g, b )
    red = r/255
    green = g/255
    blue = b/255

    return red, green, blue
end

function indicador_barra_h(x, y, valor, max, log, red, green, blue)
    --SETTINGS FOR CPU INDICATOR BAR
    bar_bottom_left_x = x
    bar_bottom_left_y = y
    bar_width = 100
    bar_height = 5

    --set bar background colors
    bar_bg_red,bar_bg_green,bar_bg_blue=rgb(200,200,200)
    bar_bg_alpha=1

    --set indicator colors
    bar_in_red=red
    bar_in_green=green
    bar_in_blue=blue
    bar_in_alpha=1

    --draw background
    cairo_set_source_rgba(cr, bar_bg_red, bar_bg_green, bar_bg_blue, bar_bg_alpha)
    cairo_rectangle(cr, bar_bottom_left_x, bar_bottom_left_y, bar_width, -bar_height)
    cairo_fill (cr)

    if log == true then
      -- Logarithmic scale
      minp = 0
      maxp = bar_width

      -- The result should be between 100 and max
      minv = math.log(1)
      maxv = math.log(max)

      -- calculate adjustment factor
      scale = (maxv-minv) / (maxp-minp)

      indicator_width = math.exp(minv + scale*(valor-minp))
    else
--      proportion = valor/max
--      indicator_width=proportion*bar_width
--      100 мегабит/cек = 100 000 килобит в секунду (в килбитах в сек считает downspeedf)
--      сетевая карта на серваке - 100 мегабитная, отталкиваемся от неё, как от макс скорости
--      valor = текущая скорость закачки/скачки, но это не максимальная.
--	В общем, надо переделать потом
	indicator_width = valor/1000
    end

    --draw indicator
    cairo_set_source_rgba (cr, bar_in_red, bar_in_green, bar_in_blue, bar_in_alpha)
    cairo_rectangle (cr, bar_bottom_left_x, bar_bottom_left_y, indicator_width, -bar_height)
    cairo_fill (cr)
end

function indicador_arco(x, y, valor, label, red, green, blue)
    --SETTINGS
    --rings size
    ring_center_x=x
    ring_center_y=y

    ring_radius=19
    ring_width=5

    --colors
    --set background colors
    ring_bg_red, ring_bg_green, ring_bg_blue=rgb(200,200,200)
    ring_bg_alpha=1

    --set indicator colors
    ring_in_red=red
    ring_in_green=green
    ring_in_blue=blue
    ring_in_alpha=1

    --indicator value settings
    value=valor
    max_value=100

    --draw background
    cairo_set_line_width (cr,ring_width)
    cairo_set_source_rgba (cr,ring_bg_red,ring_bg_green,ring_bg_blue,ring_bg_alpha)
    cairo_arc (cr,ring_center_x,ring_center_y,ring_radius,0,2*math.pi)
    cairo_stroke (cr)

    cairo_set_line_width (cr,ring_width)
    start_angle = angulo(0)
    end_angle=angulo( value*(360/max_value) )

    --print (end_angle)
    cairo_set_source_rgba (cr,ring_in_red,ring_in_green,ring_in_blue,ring_in_alpha)
    cairo_arc (cr,ring_center_x,ring_center_y,ring_radius,start_angle,end_angle)
    cairo_stroke (cr)

    -- Label
    -- Centraliza o texto no arco
    local extents = cairo_text_extents_t:create()
    tolua.takeownership(extents)
    cairo_text_extents(cr, label, extents)
    x = ring_center_x - (extents.width / 2 + extents.x_bearing)
    y = ring_center_y - (extents.height / 2 + extents.y_bearing) - 7

    texto(my_bool, label, x, y, red, green, blue )

    txt = valor .. "%"
    cairo_text_extents(cr, txt, extents)
    x = ring_center_x - (extents.width / 2 + extents.x_bearing)
    y = ring_center_y - (extents.height / 2 + extents.y_bearing) + 7

    texto(my_bool, txt, x, y, red, green, blue )
end

function texto(my_bool,txt, x, y, r, g, b)
    -- Configura o tipo e o tamanho da fonte que será utilizada
    font="Ubuntu Mono"
    if my_bool == true then
        font_size=14
    else
    font_size=10
    end
    font_slant=CAIRO_FONT_SLANT_NORMAL
    font_face=CAIRO_FONT_WEIGHT_BOLD

    -- Inicializa o Cairo com as configurações de fontes
    cairo_select_font_face (cr, font, font_slant, font_face);
    cairo_set_font_size (cr, font_size)

    text=txt
    xpos,ypos=x,y
    red,green,blue = r,g,b
    alpha=1
    cairo_set_source_rgba (cr,red,green,blue,alpha)

    cairo_move_to (cr,xpos,ypos)
    cairo_show_text (cr,text)
    cairo_stroke (cr)
end

function conky_main()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    cr = cairo_create(cs)

    -- Indicador CPU
    my_bool = false
    y=28
    x=34
    valor = conky_parse("${cpu cpu0}")
    indicador_arco(x, y, valor, "CPU", rgb(255, 117, 49))

    y=28
    x=80
    valor = conky_parse("${cpu cpu1}")
    indicador_arco(x, y, valor, "CPU", rgb(255, 117, 49))
    
    y=28
    x=126
    valor = conky_parse("${cpu cpu2}")
    indicador_arco(x, y, valor, "CPU", rgb(255, 117, 49))

    y=28
    x=172
    valor = conky_parse("${cpu cpu3}")
    indicador_arco(x, y, valor, "CPU", rgb(255, 117, 49))
    
    
    -- Indicador RAM
    y=28
    x=330
    valor = conky_parse("${memperc}")
    indicador_arco(x, y, valor, "RAM", rgb(255, 255, 112))

    -- Indicador SWAP
    y=28
    x=380
    valor = conky_parse("${swapperc}")
    indicador_arco(x, y, valor, "swap", rgb(220, 127, 220))

    -- Indicador Disco (Root)
    y=28
    x=430
    valor  = 100-tonumber(conky_parse("${fs_free_perc /}"))
    indicador_arco(x, y, valor, "/", rgb(141, 255, 141))


    -- Indicador Disco (Boot)
    y=28
    x=480
    valor  = 100-tonumber(conky_parse("${fs_free_perc /boot}"))
    indicador_arco(x, y, valor, "boot", rgb(0, 164, 209))

    -- Indicador Disco (Home)
    y=28
    x=530
    valor  = 100-tonumber(conky_parse("${fs_free_perc /home}"))
    indicador_arco(x, y, valor, "home", rgb(141, 255, 141))

    -- Indicador Disco (/mnt/servak)
    y=28
    x=580
    valor  = 100-tonumber(conky_parse("${fs_free_perc /mnt/servak}"))
    indicador_arco(x, y, valor, "servak", rgb(0,206,209))

    -- Indicadores Eth
--  y=13
--  x=200
--  txt="Eth:"
    log = false
--  texto(my_bool, txt, x, y, rgb(106,90,205))
    x=205
    y=17
    my_bool = true
    txt=conky_parse("${addrs enp3s0}")
    texto(my_bool,txt, x, y, rgb(106,90,205))


    y = 32
    txt=conky_parse("dn ${downspeedf enp3s0} кб/c")
    texto(my_bool,txt,x,y,rgb(106,90,205))

    y = 45
    txt=conky_parse("up ${upspeedf enp3s0} кб/c")
    texto(my_bool,txt,x,y,rgb(106,90,205))


--[[
    -- Upload
    my_bool = false
    x=200
    y=33
    valor = tonumber(conky_parse("${upspeedf enp3s0}"))
    max = 50
    indicador_barra_h(x, y, valor, max, log, rgb(106,90,205))

    -- Download
    y=45
    valor = tonumber(conky_parse("${downspeedf enp3s0}"))
    max = 50
    indicador_barra_h(x, y, valor, max, log, rgb(255,127,80))

 ]]

-- здесь был финиш, but me..
--
    
    my_bool = true
    y=13
    x=610
--    local my_str = "${exec dmesg | tail -n3}"
    --txt = "hasfafafafafafaffha"
    local my_str = "${exec dmesg | tail -n3}"
    txt = conky_parse(my_str)
    dokuda = string.find(txt,"]")
    txt_str = string.sub(txt,dokuda+1)
    i_dokuda = string.find(txt_str,"%[ ")
    first_stroke = string.sub(txt_str,1,i_dokuda-2)
    texto(my_bool, first_stroke, x, y, rgb(106,90,205))
    second_stroke = string.sub(txt_str,i_dokuda+14)
    y=30
    local i_dokuda_1 = string.find(second_stroke,"%[ ")
    second_real_stroke=string.sub(second_stroke,1,i_dokuda_1-2)
    texto(my_bool,second_real_stroke, x, y, rgb(106,90,205))
    third_stroke=string.sub(second_stroke,i_dokuda_1+14)
    y=47
    texto(my_bool, third_stroke,x,y,rgb(106,90,205))
--[[
    print("********first********")
    print(first_stroke)
    print("********second********")
    print(second_stroke)
    print("********second_real****")
    print(second_real_stroke)
    print("********third**********")
    print(third_stroke)
]]


    -- Indicadores Eth_rezerv
--    x=600
--    y=100
--    txt="Eth1:"
--    texto(txt, x, y, rgb(244,164,96))

 --   x=614
  --  txt=conky_parse("${addrs enp3s0}")
   -- texto(txt, x, y, rgb(244,164,96))

    -- Upload
    --x=624
--    valor = tonumber(conky_parse("${upspeedf enp3s0}"))
--    max = 1500
 --   indicador_barra_h(x, y, valor, max, log, rgb(106,90,205))

    -- Download
  --  x=640
   -- max = 5000
    --valor = tonumber(conky_parse("${downspeedf enp3s0}"))
--    indicador_barra_h(x, y, valor, max, log, rgb(255,127,80))

--    y=700
--    txt = conky_parse("${upspeedf enp3s0}")
--    texto(txt, x, y, rgb(244,164,96))
--    y=720
--    txt = conky_parse("${downspeedf enp3s0}")
--    texto(txt, x, y, rgb(244,164,96))

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
