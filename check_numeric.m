function out = check_numeric(in)
    out = in;
    if(~isnumeric(out))
        out = str2double(in);
    end
end

