function out = check_numeric(in)
    in = check_cell(in);
    out = in;
    if(~isnumeric(out))
        out = str2double(in);
    end
end

