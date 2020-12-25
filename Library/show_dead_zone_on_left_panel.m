function show_dead_zone_on_left_panel( fig_handle, lineLength_1side, sizeX, sizeY, color, faceAlpha)

L = lineLength_1side;

subplot(2,3,[1 4]);

fill([1 1 L L],[1 sizeY sizeY 1],color,'FaceAlpha',faceAlpha,'LineStyle','none')
fill([sizeX-L sizeX-L sizeX sizeX],[1 sizeY sizeY 1],color,'FaceAlpha',faceAlpha,'LineStyle','none')
fill([L L sizeX-L sizeX-L],[1 L L 1],color,'FaceAlpha',faceAlpha,'LineStyle','none')
fill([L L sizeX-L sizeX-L],[sizeY-L sizeY sizeY sizeY-L],color,'FaceAlpha',faceAlpha,'LineStyle','none')

end

