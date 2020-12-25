% Particle Analysis Assistant

% Part 4 - Display statistics

% Load Grouped_Data
% Output stats graphs on radii measurements

%% Load Grouped_data
clear; clc; close all;

[grouped_data_name, folder_path] = uigetfile();
load([folder_path grouped_data_name]);

%% Sorting into SampleTypes

sample_types = {'TG','PAA'};

empty_container = {[],[]};

all_accepted_radii_um_preEx = empty_container;
particle_avg_accepted_radii_um_preEx = empty_container;
all_normalized_radii = empty_container;
particle_avg_normalized_radii = empty_container;
particle_std_normalized_radii = empty_container;
particle_std_radii = empty_container;
all_accepted_gaufit2_sigma_um_preEx = empty_container;
particle_avg_accepted_gaufit2_sigma_um_preEx = empty_container;

for p = 1:length(particle_data)
    
    sample_type_index = find(strcmp(sample_types, particle_data(p).sample_type));
    if length(sample_type_index) ~= 1
        continue
        error('Incorrect sample type label.');
    end
    
    all_accepted_radii_um_preEx{sample_type_index} = [...
        all_accepted_radii_um_preEx{sample_type_index} ; ...
        particle_data(p).accepted_radii_um_preEx_vector] ;
    
    particle_avg_accepted_radii_um_preEx{sample_type_index} = [...
        particle_avg_accepted_radii_um_preEx{sample_type_index} ; ...
        particle_data(p).avg_of_accepted_radii_um_preEx];
    
    all_normalized_radii{sample_type_index} = [...
        all_normalized_radii{sample_type_index} ; ...
        particle_data(p).normalized_radii_vector];
    
    particle_avg_normalized_radii{sample_type_index} = [...
        particle_avg_normalized_radii{sample_type_index} ; ...
        particle_data(p).avg_of_normalized_radii];
    
    particle_std_normalized_radii{sample_type_index} = [...
        particle_std_normalized_radii{sample_type_index} ; ...
        particle_data(p).std_of_normalized_radii];
    
    particle_std_radii{sample_type_index} = [...
        particle_std_radii{sample_type_index} ; ...
        particle_data(p).std_of_radii];
    
    all_accepted_gaufit2_sigma_um_preEx{sample_type_index} = [...
        all_accepted_gaufit2_sigma_um_preEx{sample_type_index} ; ...
        particle_data(p).accepted_single_profile_sigma_um_preEx_vector];
    
    particle_avg_accepted_gaufit2_sigma_um_preEx{sample_type_index} = [...
        particle_avg_accepted_gaufit2_sigma_um_preEx{sample_type_index} ; ...
        particle_data(p).avg_of_accepted_single_profile_sigma_um_preEx_vector];
    
end

all_accepted_gaufit2_sigma_um_preEx_pooled_both_gels = [all_accepted_gaufit2_sigma_um_preEx{1};all_accepted_gaufit2_sigma_um_preEx{2}];
median_PAA_gaufit2_sigma_preEx_nm = median(all_accepted_gaufit2_sigma_um_preEx{1}) .* 1000
median_TG_gaufit2_sigma_preEx_nm = median(all_accepted_gaufit2_sigma_um_preEx{2}) .* 1000
median_pooled_gaufit2_sigma_preEx_nm = median(all_accepted_gaufit2_sigma_um_preEx_pooled_both_gels) .* 1000


%% Plotting statistics from radii analysis

% Turn non-normalized radii into nm
particle_std_radii_um = particle_std_radii;
particle_std_radii_nm = cellfun(@(x) x.* 1000, particle_std_radii_um,'UniformOutput',false);

comparisons = {...
    all_accepted_radii_um_preEx ; ...
    particle_avg_accepted_radii_um_preEx ; ...
    particle_std_normalized_radii ; ...
    particle_std_radii_nm; ...
    };

title_strings = {...
    sprintf('All accepted \nindividual radii'); ...
    sprintf('Average radii \nof particles'); ...
    sprintf('Standard deviation of \nnormalized radii in particles');...
    sprintf('Standard deviation of \nnon-normalized radii in particles')} ;

x_shift = 0.1;

yLims = {[0 0.35],[0 0.25],...
    [0 1.2],[0 120]};

% Box plots
fig_handle = figure(2);clf; hold on;

for c = 1:length(comparisons)
    
    subplot(1,length(comparisons),c);
 
    vals = [];
    grouping_var = [];
    for i = 1:length(sample_types)
        vals = [ vals ; comparisons{c}{i}];
        grouping_var = [grouping_var ; repmat(sample_types(i),length(comparisons{c}{i}),1) ];
    end
  
    boxplot(vals,grouping_var,'symbol','k+','outliersize',4,'widths',0.4,'colors','k',...
        'whisker',1.5);

    xtickangle(45)
  
    title(sprintf([title_strings{c} '\n' ...
        ]));
    ylim(yLims{c});
end

%% Plotting statistics from shape analysis

gel_type = {'TG','PAA'};

fields_to_collect = {'eccentricity', 'sphericity','normalized_circ_std'};

title_string = {...
    ['Eccentricity \n(minor axis length / major axis length)'],...
    ['Sphericity \n(R-inscribing / R-circumscribing)'],...
    ['Normalized circular standard deviation \n(std on radii, divided by (particle mean radii))'],...
};

yLims = {[0.5 1.1],[0.2 1.1],[0 0.70]};

empty_struct.gel_type = [];
for f = 1:length(fields_to_collect)
    empty_struct.(fields_to_collect{f}) = [];
end

virus_stats_by_gel = [empty_struct , empty_struct];

virus_stats_by_gel(1).gel_type = gel_type{1};
virus_stats_by_gel(2).gel_type = gel_type{2};

for p = 1:length( particle_shape_data )
    
    gel_type_index = find( strcmp( gel_type, particle_shape_data(p).gel_type ) );
    
    if length(gel_type_index) ~= 1
        error('Gel type mismatch.');
    end
    
    for f = 1:length(fields_to_collect)
        virus_stats_by_gel(gel_type_index).(fields_to_collect{f}) = ...
            [virus_stats_by_gel(gel_type_index).(fields_to_collect{f}) , ...
            particle_shape_data(p).(fields_to_collect{f})];
    end
    
end

for f = 1:length(fields_to_collect)
    [ stats_result.(['p_' fields_to_collect{f}]) stats_result.(['h_' fields_to_collect{f}]) ] =...
        ranksum( virus_stats_by_gel(1).(fields_to_collect{f}) , ...
        virus_stats_by_gel(2).(fields_to_collect{f}) );
end

% Plotting
figure(3);clf; hold on;

for f = 1:length(fields_to_collect)
    
    subplot(1,3,f);
 
    vals = [];
    grouping_var = [];
    for g = 1:length(gel_type)
        vals = [ vals ; virus_stats_by_gel(g).(fields_to_collect{f})' ];
        grouping_var = [grouping_var ; ...
            repmat(gel_type(g),length(  virus_stats_by_gel(g).(fields_to_collect{f})  ),1) ];
    end
  
    boxplot(vals,grouping_var,'symbol','k+','outliersize',4,'widths',0.4,'colors','k',...
        'whisker',1.5);

    title(sprintf([title_string{f} '\n' ...
        ]));
    ylim(yLims{f});
    
end
