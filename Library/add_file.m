function add_file(annotator, type, path, name)

global datafiles;

switch type
    case 'Z'
        index = 1;
    case 'C'
        index = 2;
    otherwise
        error('No type matching.');
end

datafile.path = path;
datafile.name = name;
datafile.annotator = annotator;
datafile.type = type;


datafiles{index} = [datafiles{index} datafile];