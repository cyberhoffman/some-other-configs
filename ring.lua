settings_table = {
    {
        name='cpu',
        arg='cpu0',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xD60650,
        fg_alpha=1.0,
        x=50, y=50,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
 
    {
        name='cpu',
        arg='cpu1',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xD60650,
        fg_alpha=1.0,
        x=150, y=50,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
    {
        name='cpu',
        arg='cpu2',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xD60650,
        fg_alpha=1.0,
        x=50, y=150,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
    {
        name='cpu',
        arg='cpu3',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xD60650,
        fg_alpha=1.0,
        x=150, y=150,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
{
        name='memperc',
        arg='',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xD60650,
        fg_alpha=1.0,
        x=100, y=250,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },



        {
        name='downspeedf',
        arg='wlp1s0',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0x339900,
        fg_alpha=1.0,
        x=50, y=350,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
        {
        name='upspeedf',
        arg='wlp1s0',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xFF8700,
        fg_alpha=1.0,
        x=150, y=350,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },
        {
        name='battery_percent',
        arg='BAT0',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=1.0,
        fg_colour=0xFF8700,
        fg_alpha=1.0,
        x=100, y=445,
        radius=25,
        thickness=15,
        start_angle=-135,
        end_angle=135
    },

}
 
require 'cairo'
 
function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end
function draw_ring(cr,t,pt)

    local w,h=conky_window.width,conky_window.height
    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']
    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)
    -- загрузка фона кольца
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)
    -- загрузка кольца
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)        
    --Пишем текст-----
--[[    local my_f = io.popen("sensors | grep Phys | awk '{print $4}'")
    local my_l = my_f:read("*a") -- эта хрень поднимает температуру до 60
    my_l=string.sub(my_l,1,8)
    my_f:close()

    local my_l = string.format('${acpitemp}')
    local str1=conky_parse(my_l)
    cairo_move_to (cr, 60,110)
    cairo_set_font_size(cr,22)
    cairo_show_text(cr, str1)
    cairo_stroke (cr)
 ]] 
  
end
function conky_ring_stats()
    local function setup_rings(cr,pt)
        local str=''
        local value=0
        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)
         
        value=tonumber(str)
        if value == nil then value = 0 end
        pct=value/pt['max']
         
        draw_ring(cr,pct,pt)
    end
end


function conky_clock_rings()

    local function setup_rings(cr,pt)
        local str=''
        local value=0
  
        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)
  
        value=tonumber(str)
        pct=value/pt['max']
  
        draw_ring(cr,pct,pt)
    end
  
    -- Проверка, что conky работают последнии 5 секунд
  
    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
  
    local cr=cairo_create(cs)   
  
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
  
    if update_num>5 then
        for i in pairs(settings_table) do
            setup_rings(cr,settings_table[i])
        end
    end
end
