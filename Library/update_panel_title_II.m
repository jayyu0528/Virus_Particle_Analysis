function update_panel_title_II(fig_handle, sub_panel_index, text, fontsize, fontcolor)

global global_font_size_modifier;

figure(fig_handle);
subplot(4,3,sub_panel_index);
title(text,'fontsize',fontsize * global_font_size_modifier,'color',fontcolor);