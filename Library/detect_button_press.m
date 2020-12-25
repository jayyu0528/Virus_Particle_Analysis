function [ value ] = detect_button_press( )
waitforbuttonpress;
value = double(get(gcf,'CurrentCharacter'));

end

