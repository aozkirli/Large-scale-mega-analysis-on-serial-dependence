function out = check_set_variables(names,values,input,def)
if ~nnz(ismember(names,input))
    out      = def;
else
    out      = values{ismember(names,input)};
end
end
