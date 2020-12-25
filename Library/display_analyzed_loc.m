function display_analyzed_loc( fig_handle, particle_data )

figure(fig_handle);
subplot(2,3,[1 4]);

for p = 1:length(particle_data.Measurements)
    
    switch particle_data.Measurements(p).Acceptance
        case 'Accepted'
            fontcolor = [1 0 0];
        case 'Rejected'
            fontcolor = [0 1 1];
    end
    
    text(particle_data.Measurements(p).X_loc, ...
        particle_data.Measurements(p).Y_loc, ... 
        num2str(particle_data.Measurements(p).Index), ...
        'horizontalalignment','center','color',fontcolor, ...
        'fontsize',12','fontweight','bold')
end

end

