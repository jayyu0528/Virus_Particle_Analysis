function answer = find_closest_even_integer(A)

if mod(A,2) == 0 % A is a even number
    answer = A;
elseif mod(A,2) == 1 % A is a odd number
    answer = A + 1; % arbitrarily assign to the larger one
elseif mod(A,2) > 1
    answer = ceil(A);
elseif mod(A,2) < 1
    answer = floor(A);
end
