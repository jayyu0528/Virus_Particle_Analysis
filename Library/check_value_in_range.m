function tf = check_value_in_range(x, low, high)
% boundary is inclusive
tf = (x >= low) && (x <= high);