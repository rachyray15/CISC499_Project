function BATS

    f = figure('Visible','off', 'Position', [300,400,800,800], 'Name', 'Beacon Attraction Trajectory Simulation', 'NumberTitle', 'off', 'menubar', 'none'); %Visible off while adding components, Size of window, Name of figure, Turn off the figure number
    sp = subplot('Position', [0.15 0.2 0.7 0.7], 'xtick',[],'ytick',[]); %position the plot inside the window
    mode = uibuttongroup('Visible','off','Position', [0 0 20 0.12]); %section where the buttons are, visible off until all buttons added, position the section
    beacon = uicontrol(mode,'Style', 'radiobutton', 'String','B.A.T.', 'Position',[6 35 100 30], 'HandleVisibility','off', 'Callback', @func);%Beacon mode, radiobutton, calls function           
    shortPath = uicontrol(mode,'Style','radiobutton','String','S.P.', 'Position',[6 5 100 30], 'HandleVisibility','off', 'Callback', @func);%Shortest path mode, radiobutton, calls function 
    polygon = uicontrol(mode,'Style', 'popup', 'String', {'Polygon1', 'Polygon2', 'Polygon3'}, 'Position', [100 24 100 20], 'Callback', @changePolygon);%selects polygon to use, dropdown menu, calls function changePolygon    
    start = uicontrol(mode, 'Style', 'pushbutton', 'String', 'Start!', 'Position', [400 24 100 20], 'Callback', @findPath); %Start the trajectory after mode and polygon selected
    
    mode.Visible = 'on';%show the buttons
      
    function changePolygon(source,event)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        % Set current data to the selected data set.
        switch str{val};
            case 'Polygon1' %create the first polygon
                cla reset;
                set(sp,'xtick',[],'ytick',[]);%hide the axis
                axis([-1 11 -0.5 3.5])
                px = [0.2 3.3 4.7 5.4 10 9.8 3.6 3.8 2.6 2.5 0.8 1.3 0];
                py = [0 0 2.6 0 0 3 3 1.9 2.6 1.2 1.8 0.7 1.5];
                patch(px, py, 'red');
                
                %create the beacon
                bx = [1.5 1.7 1.9];
                by = [0.25 0.5 0.25];
                patch(bx, by, 'blue');
                
                %create the point
                ct = linspace(0, 2*pi);
                cr = 0.1;
                cx = cr*cos(ct) + 9;
                cy = cr*sin(ct) + 0.25;
                patch(cx, cy, 'green');
                
            case 'Polygon2' %create the second polygon
                cla reset;
                set(sp,'xtick',[],'ytick',[]);%hide the axis
                axis([-0.5 6 -0.5 6])
                px = [3.5 5 4.4 3.2 2.5 2.2 1.9 1.5 1.2 0 0.5 3.3];
                py = [0 0 5 5 3.6 5 3.5 5 3.6 5 1.5 4.1];
                patch(px, py, 'green');
                
                %create the beacon
                bx = [0.7 0.85 1];
                by = [2.5 2.9 2.5];
                patch(bx, by, 'blue');
                
                %create the point
                ct = linspace(0, 2*pi);
                cr = 0.1;
                cx = cr*cos(ct) + 4.5;
                cy = cr*sin(ct) + 0.5;
                patch(cx, cy, 'red');
                
            case 'Polygon3' %create the third polygon
                cla reset;
                set(sp,'xtick',[],'ytick',[]); %hide the axis
                axis([0.5 7.5 -0.5 4.5])
                px = [1 1.5 2 2.3 3 3.2 4.5 4 7 5.5 3 2.1 1.3 1];
                py = [0 0 1.5 0.7 1.3 1.5 1.7 0 0 4 3 3.2 2.5 3];
                patch(px, py, 'blue');
                
                %create the beacon
                bx = [1.1 1.25 1.4];
                by = [0.2 0.45 0.2];
                patch(bx, by, 'green');
                
                %create the point
                ct = linspace(0, 2*pi);
                cr = 0.1;
                cx = cr*cos(ct) + 6;
                cy = cr*sin(ct) + 0.3;
                patch(cx, cy, 'red');
        end
    end

    function findPath() 
        %depending on wether BAT or SH
    end

    f.Visible = 'on'; %make entire figure visible
end

%create findPath call back function for start button