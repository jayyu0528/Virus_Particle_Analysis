function save_data_and_close_figure(filename_prefix, fig_handle, particle_data_2, contrast_low, contrast_high, accepted_particle_indices, p, lineLength2, sample_type, varargin)

if ~isempty(varargin)
    if isa(varargin{1},'MException')
        curr_exception = varargin{1};
    else
        error('Extra input argument does not correspond to MException error.');
    end
end

currTime = clock;
timestamp = [num2str(currTime(1)*10000+ currTime(2) * 100 + currTime(3)) '-' num2str(currTime(4),'%.2d') '-' num2str(currTime(5),'%.2d')];
saveName = [filename_prefix timestamp];
if exist('curr_exception','var')
    save(saveName,'particle_data_2','sample_type','contrast_low','contrast_high','accepted_particle_indices','p','lineLength2','curr_exception');
else
    save(saveName,'particle_data_2','sample_type','contrast_low','contrast_high','accepted_particle_indices','p','lineLength2');
end
disp(sprintf(['\n==========================================\n' saveName ' has been saved.\n==========================================\n']));
close(fig_handle);