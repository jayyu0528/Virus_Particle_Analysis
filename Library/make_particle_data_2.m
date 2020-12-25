function particle_data_2 = make_particle_data_2(particle_data)

% Create new mother data file
particle_data_2 = rmfield(particle_data,'Measurements');
particle_data_2.DiameterMeasurements = particle_data.Measurements;