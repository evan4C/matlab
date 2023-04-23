% 打断当前模块的库连接
set_param(gcb, 'LinkStatus', 'none');

% 删去封装中的初始化命令asm_blockini;
maskObj = Simulink.Mask.get(gcb);
maskObj.Initialization = '';

% 获取参数数量和对应的名称
MP = maskObj.Parameters;
numParams = numel(MP) - 3;

% 查找变量为Licdata.Lic1~N.v的模块，并对其变量进行更改
for i = 1:numParams
    blockValue = ['Licdata.Lic' num2str(i) '.v'];
    newValue = [MP(i).Name '.v'];
    % 符合条件的Constant模块
    constBlocks = find_system(gcb,'LookUnderMasks','all','BlockType','Constant','Value', blockValue);
    if ~isempty(constBlocks)
        set_param(constBlocks{1}, 'value', newValue);
        disp([blockValue ' constBlock replace succeed']);
    end

    % 符合条件的Gain模块
    gainBlocks = find_system(gcb,'LookUnderMasks','all', 'Gain', blockValue);
    if ~isempty(gainBlocks)
        set_param(gainBlocks{1}, 'Gain', newValue);
        disp([blockValue ' gainBlock replace succeed']);
    end

    % 符合条件的LUT模块
    tableBlocks = find_system(gcb,'LookUnderMasks','all','tableData', blockValue);
    
    if ~isempty(tableBlocks)
        % 判断LUT维度
        d_LUT = str2double(get_param(tableBlocks{1}, 'NumberOfTableDimensions'));
        if d_LUT == 1
            set_param(tableBlocks{1}, 'tableData', newValue);
            newDimension = [MP(i).Name '.x'];
            set_param(tableBlocks{1}, 'BreakpointsForDimension1', newDimension);
            disp([blockValue ' 1DLUT replace succeed']);
        elseif d_LUT == 2
            set_param(tableBlocks{1}, 'tableData', newValue);
            newDimension1 = [MP(i).Name '.x'];
            set_param(tableBlocks{1}, 'BreakpointsForDimension1', newDimension1);
            newDimension2 = [MP(i).Name '.y'];
            set_param(tableBlocks{1}, 'BreakpointsForDimension2', newDimension2);
            disp([blockValue ' 2DLUT replace succeed']);
        end
    end

    % 符合条件的Saturation模块
    sauBlocks = find_system(gcb,'LookUnderMasks','all', 'UpperLimit', blockValue);
    salBlocks = find_system(gcb,'LookUnderMasks','all', 'LowerLimit', blockValue);
    if ~isempty(sauBlocks)
        set_param(sauBlocks{1}, 'UpperLimit', newValue);
        disp([blockValue ' saturationBlock replace succeed']);
    elseif ~isempty(salBlocks)
        set_param(salBlocks{1}, 'LowerLimit', newValue);
        disp([blockValue ' saturationBlock replace succeed']);
    end
end



