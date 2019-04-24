function [interp, interp_arr, val, weight_arr] = extract_vd_info(vd_table, index)
    % extract_vd_info Utility function to extract specific vd information
    interp_arr = [];
    interp = 0;
    val = 0;
    weight_f = 0;
    weight_r = 0;
    weight_s = 0;
    if(isnan(vd_table{1, index}))
        interp = 1;
        interp_arr = nan_end_extract(vd_table{2:end, index});
        weight_f = nan_end_extract(vd_table{2:end, index+1});
        weight_r = nan_end_extract(vd_table{2:end, index+2});
        weight_s = nan_end_extract(vd_table{2:end, index+3});
        weight_arr = [interp_arr, weight_f, weight_r, weight_s];
    else
        val = check_numeric(vd_table{1, index});
        weight_f = check_numeric(vd_table{1, index+1});
        weight_r = check_numeric(vd_table{1, index+2});
        weight_s = check_numeric(vd_table{1, index+3});
        weight_arr = [val, weight_f, weight_r, weight_s];
    end
end

