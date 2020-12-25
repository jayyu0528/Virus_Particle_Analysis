function update_panel_title( fig_handle, panel_index , text , fontsize )
    
    % panel index
    % 1 = left (global view)
    % 2 = mid (zoomed view)
    % 3 = right top (line profile 1)
    % 4 = right btm (line profile 2)
    
    switch panel_index
        case 1
            target_panel = [1 4];
        case 2
            target_panel = [2 5];
        case 3
            target_panel = 3;
        case 4 
            target_panel = 4;
    end
            

    figure(fig_handle);
    subplot(2,3,target_panel);
    title(text,'fontsize', fontsize,'Interpreter','tex');

end

