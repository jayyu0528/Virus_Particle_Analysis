function [Rdata, lin_final_output] = perform_radii_analysis_on_ROI(workspace2_name)


global particle_radii_count_thres;

normalization_mode = 'AVG of particle''s accepted radii from Rdata'


%% Load Individual ROI's Workspace2

% load('/Users/Jay/Documents/MATLAB/Tetragel_Related/Virus_Particle_Analysis/Samples/180329_H20Z1A1_cf_640_0.25z_30%laser_Stack_60x(1.5xtube)_two_cmle-3-1/Workspace2_20180831-16-14.mat')

load(workspace2_name);

%%

% Note that p variable refers to Wdata's index, which
% is different from Ddata's index (shared by "Index" field)
Ddata = particle_data_2.DiameterMeasurements;
Wdata = particle_data_2.WidthMeasurements;

Rdata = struct([]);

lin_final_output = [];
lin_final_output_tag = 'radius_p_size_normalized from all accepted profiles of all accepted particles';

for p = 1:length(Wdata)
    
    % 3 steps:
    % Get diagnol-corrected radii
    % Determine normalization quantity of the particle
    % Normalize radii, conditionally write value into output
    
    % Only consider (gaufit2_result-)Accepted Peaks
    % Might later add more exclusion conditions
    
    % For now - accept all
    Rdata(p).Acceptance_as_radius = Wdata(p).Acceptance_peaks;
    
    Rdata(p).radius_px_diag_adjusted = zeros(4,2);
    Rdata(p).radius_um_diag_adjusted = zeros(4,2);
    Rdata(p).radius_p_size_normalized = zeros(4,2);
    
    % Compute diagnal-corrected radii (but not normalized yet)
    for i = 1:4
        for j = 1:2
            % compute radii only for accepted profiles
            if Rdata(p).Acceptance_as_radius(i,j)
                
                gaufit_mu = Wdata(p).gaufit2_outputs(i,j).mu;
                
                switch j
                    case 1 % first half of L_profiles
                        r_formula = @(mu) Wdata(p).LineLength2 - mu + 1;
                    case 2 % second half of L_profiles
                        r_formula = @(mu) mu;
                end
                
                switch mod(i,2)
                    case 1 % row 1 and 3, no need for diagnol adj
                        diag_factor = 1;
                    case 0 % row 2 and 4
                        diag_factor = sqrt(2);
                end
                
                Rdata(p).radius_px_diag_adjusted(i,j) = r_formula(gaufit_mu) .* diag_factor;
                Rdata(p).radius_um_diag_adjusted(i,j) = Rdata(p).radius_px_diag_adjusted(i,j) .* particle_data_2.PixelSize_um;            
                
            end
        end
    end
    
    % Determine normalizer value
    switch normalization_mode
        case 'AVG of 2 diameters from WData'
            % Define particle size as avg of 2
            % manually-inspected particle diameters
            
            % Search for the particle diameter in Ddata
            % (whose index is different from Wdata, due
            % to rejections at the Wdata stage, etc.)
            Dindex = find([Ddata.Index] == Wdata(p).Index);
            if length(Dindex) ~= 1
                error('Error in searching for index in Ddata.')
            end
            Rdata(p).particle_size = mean([Ddata(Dindex).Diameter1_um , Ddata(Dindex).Diameter2_um]);
            Rdata(p).particle_size_tag = 'AVG of 2 manually inspected diameters';
        case 'AVG of particle''s accepted radii from Rdata'
            particle_accepted_radii = Rdata(p).radius_um_diag_adjusted(Rdata(p).Acceptance_as_radius > 0);
            Rdata(p).particle_size = mean(particle_accepted_radii);
            Rdata(p).particle_size_tag = 'AVG of particle''s  accepted radii from Rdata';
            
            Rdata(p).particle_radii_count_thres = particle_radii_count_thres;
            if length(particle_accepted_radii) >= particle_radii_count_thres
                Rdata(p).particle_has_sufficient_radii = 1;
            else
                Rdata(p).particle_has_sufficient_radii = 0;
            end
            
    end
    
    
    % Normalize radii, and conditionally write into output
    for i = 1:4
        for j = 1:2
            % normalize and compile radii only for
            % accepted profiles
            if Rdata(p).Acceptance_as_radius(i,j)
                
                Rdata(p).radius_p_size_normalized(i,j) = Rdata(p).radius_um_diag_adjusted(i,j) ./ Rdata(p).particle_size;
                
                % Determine whether to write into lin_final_output or not
                switch normalization_mode
                    case 'AVG of 2 diameters from WData'
                        % Always write
                        write_into_lin_final_output = 1;
                    case 'AVG of particle''s accepted radii from Rdata'
                        % Only write when there are >N radii in this
                        % particle
                        if strcmp(normalization_mode, 'AVG of particle''s accepted radii from Rdata') ...
                                && Rdata(p).particle_has_sufficient_radii
                            write_into_lin_final_output = 1;
                        else
                            write_into_lin_final_output = 0;
                        end
                end
                
                if write_into_lin_final_output
                    % Concatenate linear output
                    lin_final_output = [lin_final_output, ...
                        Rdata(p).radius_p_size_normalized(i,j) ];
                end
                
            end
        end
    end
    
end
