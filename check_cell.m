function out = check_cell(in)
    if(iscell(in))
        out = in{1};
    else
        out = in;
    end
end

