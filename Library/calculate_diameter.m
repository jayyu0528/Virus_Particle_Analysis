function [ dia_pixel, dia_um ] = calculate_diameter( m1, m2, pixel_size_um )

dia_pixel = m2-m1;
dia_um = dia_pixel * pixel_size_um;

end

