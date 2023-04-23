% 创建一个模型并打开它。
open_system(new_system('connect_model'));

% 添加 Constant 模块和 Gain 模块并重命名。
add_block('simulink/Commonly Used Blocks/Constant','connect_model/Constant');
set_param('connect_model/Constant','name','newConstant');

add_block('simulink/Commonly Used Blocks/Gain','connect_model/Gain');
set_param('connect_model/Gain','name','newGain');

% 复制 Gain 模块并重命名。
copyGain = add_block('connect_model/newGain','connect_model/Gain_Copy');

% 连接这些模块。每个模块有一个端口，因此指定端口 1。
add_line('connect_model','newConstant/1','newGain/1');
add_line('connect_model','newGain/1','Gain_Copy/1');

% 添加 Add 模块。
add_block('simulink/Math Operations/Add','connect_model/Add');

add_line('connect_model', 'newGain/1', 'Add/1');
add_line('connect_model', 'Gain_Copy/1', 'Add/2');

% 添加 Scope 模块
add_block('simulink/Commonly Used Blocks/Scope','connect_model/Scope');

% 添加 Bus Creator 模块。
add_block('simulink/Commonly Used Blocks/Bus Creator','connect_model/Bus');

% 设置 Bus Creator 模块输入端口的数量并连线
bus = get_param('connect_model/Bus','Handle');
numInputs = 3;
set_param(bus, 'Inputs', num2str(numInputs));

add_line('connect_model', 'newGain/1', 'Bus/1');
add_line('connect_model', 'Gain_Copy/1', 'Bus/2');
add_line('connect_model', 'Add/1', 'Bus/3');
add_line('connect_model', 'Bus/1', 'Scope/1');

% 对信号线进行重命名
% 获取模型中的所有信号线
lines = find_system('connect_model', 'FindAll', 'on', 'Type', 'line');

% 对每条信号线进行重命名
for i = 1:length(lines)
    src_block = get_param(lines(i), 'SrcBlockHandle');
    src_block_name = get_param(src_block, 'Name');
    line_name = src_block_name;
    set_param(lines(i), 'Name', line_name);
end

% 自动布局
Simulink.BlockDiagram.arrangeSystem('connect_model')