function gaufit_output2 = perform_gaufit2_analysis(x0, y0, BKG, subtract_bkg, flatten_negative_to_zero, remove_negative_and_zero)

% Gaussian Fit 2 - direct fit on Gaussian formula
if subtract_bkg
    y0 = y0 - BKG;
    if flatten_negative_to_zero
        y0(y0 < 0) = 0;
        if remove_negative_and_zero
            x0(y0 < 0) = [];
            y0(y0 < 0) = [];
        end
    end

end

[status, sigma, mu, normFactor]= gaussfit(x0,y0);

gaufit_output2.status = status;
gaufit_output2.sigma = sigma;
gaufit_output2.mu = mu;
gaufit_output2.normFactor = normFactor;
