function BATS

    f = figure('Visible','off', 'Position', [300,400,800,800], 'Name', 'Beacon Attraction Trajectory Simulation', 'NumberTitle', 'off', 'menubar', 'none'); %Visible off while adding components, Size of window, Name of figure, Turn off the figure number
    sp = subplot('Position', [0.2 0.2 0.7 0.7]); %position the plot inside the window
    step1 = uicontrol('Style', 'text', 'String', 'Step 1: Select A Shape', 'Position', [10 570 120 20]);
    polygon = uicontrol('Style', 'popup', 'String', {'Polygon1', 'Polygon2', 'Polygon3'}, 'Position', [20 550 100 20], 'Callback', @changePolygon);%selects polygon to use, dropdown menu, calls function changePolygon    
    step2 = uicontrol('Style', 'text', 'String', 'Step 2: Select A Path Type', 'Position', [10 500 120 20]);
    pathType = uicontrol('Style', 'popup', 'String', {'B.A.T.', 'S.P.'}, 'Position',[20 470 100 30], 'HandleVisibility','off');
    step3 = uicontrol('Style', 'text', 'String', 'Step 3: Calculate Path', 'Position', [10 420 120 20]);
    start = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [20 400 100 20]); 
    reset = uicontrol('Style', 'pushbutton', 'String', 'Reset!', 'Position', [20 320 100 20], 'Callback', @resetSim); 
    G = graph(1, 1);
    pointNode = 1;
    beaconNode = 2;
    lastLineX = [0 0];
    lastLineY = [0 0];
    numNodes = 0;
    nLabel = {};
    p = plot(G);
    pathSP = 0;
    px = 0;
    py = 0;
    set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);    
    function changePolygon(source,event)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        % Set current data to the selected data set.
        switch str{val};
            case 'Polygon1' %create the first polygon
                cla reset;
                nLabel = {};
                px = [9 1.5 10 9.8 3.6 3.8 2.6 2.5 0.8 1.3 0 0.2 3.3 4.7 5.4];
                py = [0.3 0.6 0 2.4 2.4 1.3 2.2 1.1 1.7 0.9 1.3 0 0 1.7 0]; %1.7
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon((line2x(1) + line2x(2))/2, (line2y(1) + line2y(2))/2, px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;
                                    elseif inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px, py) == 0 %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                            %p = line(line2x, line2y); hold on; 
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distance = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distance; 
                end

               
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                line('XData', px(3 : numNodes), 'YData', py(3 : numNodes)); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                line('XData', lastLineX, 'YData', lastLineY); hold on;
                p = plot(G, 'w', 'XData', px, 'YData', py, 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
                pathType = uicontrol('Style', 'popup', 'String', {'B.A.T.', 'S.P.'}, 'Position',[20 470 100 30], 'HandleVisibility','off', 'Callback', @findPath);           
    
            case 'Polygon2' %create the second polygon
                cla reset;
                nLabel = {};
                px = [4.4 0.85 5 4.3 3.2 2.5 2.2 1.9 1.5 1.2 0 0.5 3.3 3.5];
                py = [0.2 2.7 0 5 5 3.6 5 3.5 5 3.6 5 1.5 4.1 0];
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;  
                                    elseif (inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px(3: numNodes), py(3: numNodes)) == 0)%line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;  
                                    elseif (inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px(3: numNodes), py(3: numNodes)) == 0) %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distance = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distance; 
                end
                
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                line('XData', px(3 : numNodes), 'YData', py(3 : numNodes)); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                line('XData', lastLineX, 'YData', lastLineY); hold on;
                p = plot(G, 'w', 'XData', px, 'YData', py, 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
                pathType = uicontrol('Style', 'popup', 'String', {'B.A.T.', 'S.P.'}, 'Position',[20 470 100 30], 'HandleVisibility','off', 'Callback', @findPath);
                
            case 'Polygon3' %create the third polygon
                cla reset;
                nLabel = {};
                px = [6.2 1.2 7 5.5 3 2.1 1.3 1 1.1 1.5 2 2.3 3.1 4.5 4];
                py = [0.3 0.3 0 4 3 3.2 2.5 3 0 0 1.5 0.7 1.3 1.7 0];
                numNodes = length(px);
                sTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                eTempNode = zeros([((numNodes+2)*(numNodes+2)) 1]);
                %drawing outline of polygon
                for j = 3 : numNodes
                    if j < numNodes
                        sTempNode(j) = j;
                        eTempNode(j) = j+1;
                    else
                        sTempNode(j) = 3;
                        eTempNode(j) = numNodes; 
                    end
                end
                %drawing intersection with beacon
                for j = 1 : numNodes
                    %looking at beacon to each point
                    for k = 3 : numNodes
                        inPoly = 0;
                        for i = 3 : numNodes
                            if k ~= j
                                if (i+1) > numNodes %need to wrap around
                                    line1x = [px(i) px(3)];
                                    line1y = [py(i) py(3)];
                                    slope1 = (line1y(1) - line1y(2))/(line1x(1) - line1x(2));
                                else
                                    line1x = [px(i) px(i+1)];
                                    line1y = [py(i) py(i+1)];
                                    slope1 = (line1y(2) - line1y(1))/(line1x(2) - line1x(1));
                                end
                                line2x = [px(k) px(j)];
                                line2y = [py(k) py(j)];
                                fit2 = polyfit(line2x, line2y, 1);
                                %check if lines are parallel
                                if k > j
                                    slope2 = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                                else
                                    slope2 = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                                end
                                %calculating intersection
                                options = optimset('Display','off');
                                fit1 = polyfit(line1x, line1y, 1);
                                x_inter = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                                y_inter = round(polyval(fit1, x_inter), 14);
                                if (i+1) > numNodes
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(3)])) && (x_inter < max([px(i) px(3)])) && (y_inter > min([py(i) py(3)])) && (y_inter < max([py(i) py(3)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;  
                                    elseif (inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px(3: numNodes), py(3: numNodes)) == 0)%line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                else
                                    if (x_inter == line2x(1) && y_inter == line2y(1)) || (x_inter == line2x(2) && y_inter == line2y(2))
                                        inPoly = inPoly;
                                    elseif (x_inter == line1x(1) && y_inter == line1y(1)) || (x_inter == line1x(2) && y_inter == line1y(2)) %intersection is a vertice
                                        inPoly = inPoly;
                                    elseif (x_inter > min([px(k) px(j)])) && (x_inter < max([px(k) px(j)])) && (y_inter > min([py(k) py(j)])) && (y_inter < max([py(k) py(j)])) && (x_inter > min([px(i) px(i+1)])) && (x_inter < max([px(i) px(i+1)])) && (y_inter > min([py(i) py(i+1)])) && (y_inter < max([py(i) py(i+1)])) %proper intersection
                                        inPoly = inPoly + 1;
                                    elseif slope1 == slope2 %parallel lines
                                        inPoly = inPoly + 1;  
                                    elseif (inpolygon(((line2x(1) + line2x(2))/2), ((line2y(1) + line2y(2))/2), px(3: numNodes), py(3: numNodes)) == 0) %line outside of polygon
                                        inPoly = inPoly + 1;
                                    else 
                                        inPoly = inPoly;
                                    end
                                end
                            end
                        end
                        
                        if inPoly == 0
                            sTempNode((15 * j) + k) = min(k, j);
                            eTempNode((15 * j) + k) = max(k, j);
                        end
                    end
                end
                numConn = length(sTempNode);
                for i = 1 : numConn
                    if sTempNode(i) == eTempNode(i)
                        sTempNode(i) = 0;
                        eTempNode(i) = 0;
                    end
                end
                sTemp2Node = sTempNode(sTempNode ~= 0);
                eTemp2Node = eTempNode(eTempNode ~= 0);
                tempNodes = [sTemp2Node eTemp2Node];
                Nodes = unique(tempNodes, 'rows');
                startNode = Nodes(:, 1);
                endNode = Nodes(:, 2);
                numConnections = length(startNode);
                for i = 1 : numConnections
                    startValue = startNode(i);
                    startX = px(startValue);
                    startY = py(startValue);
                    endValue = endNode(i);
                    endX = px(endValue);
                    endY = py(endValue);
                    distance = sqrt((abs(startX - endX).^2) + (abs(startY - endY).^2));
                    weights(i) = distance; 
                end
                
                for i = 1 : numNodes
                    if i == 1
                        nLabel(i) = {'Start Point'};
                    elseif i == 2
                        nLabel(i) = {'Beacon'};
                    else
                        nLabel(i) = {' '};
                    end
                end
                G = graph(startNode, endNode, weights);
                line('XData', px(3 : numNodes), 'YData', py(3 : numNodes)); hold on;
                lastLineX = [px(numNodes) px(3)];
                lastLineY = [py(numNodes) py(3)];
                line('XData', lastLineX, 'YData', lastLineY); hold on;
                p = plot(G, 'w', 'XData', px, 'YData', py, 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
                highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
                highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
                set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
                pathType = uicontrol('Style', 'popup', 'String', {'B.A.T.', 'S.P.'}, 'Position',[20 470 100 30], 'HandleVisibility','off', 'Callback', @findPath);
        end
    end
    
    function findPath(source,event)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        cla reset
        line('XData', px(3 : numNodes), 'YData', py(3 : numNodes)); hold on;
        line('XData', lastLineX, 'YData', lastLineY); hold on;
        p = plot(G, 'w', 'XData', px, 'YData', py, 'NodeColor', 'k', 'NodeLabel', nLabel); hold on;
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
        highlight(p, pointNode, 'NodeColor', 'm', 'MarkerSize', 10);
        highlight(p, beaconNode, 'NodeColor', 'c', 'MarkerSize', 13);
        switch str{val};
            case 'S.P.' 
                pathSP = shortestpath(G,pointNode,beaconNode);
                start = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [20 400 100 20], 'Callback', {@startPath, pathSP});
                
            case 'B.A.T.'
                 %find line from point to beacon
                startPoint = [px(1) py(1)];
                beacon = [px(2) py(2)];
                pathPosition = 1;
                pathTempX = zeros(numNodes*2);
                pathTempY = zeros(numNodes*2);
                err = 1;
                options = optimset('Display','off');
                while (startPoint(1) ~= beacon(1)) && (startPoint(2) ~= beacon(2))  
                    pathTempX(pathPosition) = startPoint(1);
                    pathTempY(pathPosition) = startPoint(2);
                    pathPosition = pathPosition + 1;
                    line1x = [startPoint(1) beacon(1)];
                    line1y = [startPoint(2) beacon(2)];
                    closestLine = 100000;
                    closestDist = 100000;
                    for i = 3 : numNodes
                        if (i+1) > numNodes
                            line2x = [px(i) px(3)];
                            line2y = [py(i) py(3)];
                            slope2(i) = (line2y(1) - line2y(2))/(line2x(1) - line2x(2));
                        else
                            line2x = [px(i) px(i+1)];
                            line2y = [py(i) py(i+1)];
                            slope2(i) = (line2y(2) - line2y(1))/(line2x(2) - line2x(1));
                        end
                        fit1 = polyfit(line1x, line1y, 1);
                        fit2 = polyfit(line2x, line2y, 1);
                        x_inter(i) = round(fzero(@(x) polyval(fit1-fit2, x), 3, options), 14);
                        y_inter = round(polyval(fit1, x_inter), 14);
                        if inpolygon(x_inter(i), y_inter(i), px, py) && (x_inter(i) > min(line2x)) && (x_inter(i) < max(line2x)) && (y_inter(i) > min(line2y)) && (y_inter(i) < max(line2y))
                            distance = sqrt((x_inter(i) - startPoint(1))^2+(y_inter(i) - startPoint(2))^2);
                            if (distance < closestDist) && (x_inter(i) < startPoint(1))
                                closestLine = i;
                                closestDist = distance;
                            end
                        end
                    end
                    %find intersecting line with perpendicular
                    if closestLine ~= 100000 && (closestLine + 1) > numNodes
                        lineInterx = [px(closestLine) px(3)];
                        lineIntery = [py(closestLine) py(3)];
                    elseif closestLine ~= 100000
                        lineInterx = [px(closestLine) px(closestLine+1)];
                        lineIntery = [py(closestLine) py(closestLine+1)];
                    end
                    if closestLine == 100000 %no intersection found inside the polygon 
                        startPoint = beacon;
                    elseif inpolygon(x_inter(closestLine), y_inter(closestLine), line1x, line1y) && (x_inter(closestLine) > min(lineInterx)) && (x_inter(closestLine) < max(lineInterx)) && (y_inter(closestLine) > min(lineIntery)) && (y_inter(closestLine) < max(lineIntery)) %proper intersection
                        pathTempX(pathPosition) = x_inter(closestLine);
                        pathTempY(pathPosition) = y_inter(closestLine);
                        pathPosition = pathPosition + 1;
                        %calculate perpendicular line
                        perpenSlope = -1/slope2(closestLine);
                        perpenB = beacon(2) - (perpenSlope * beacon(1));
                        xPerpen = -100;
                        yPerpen = (perpenSlope*xPerpen) + perpenB;
                        perpenLinex = [beacon(1) xPerpen];
                        perpenLiney = [beacon(2) yPerpen];
                        
                        %calculate intersection of perpendicular line and intersecting line
                        perFit1 = polyfit(perpenLinex, perpenLiney, 1);
                        perFit2 = polyfit(lineInterx, lineIntery, 1);
                        normalX = round(fzero(@(x) polyval(perFit1-perFit2, x), 3, options), 14);
                        normalY = round(polyval(perFit1, normalX), 14);
                        if inpolygon(normalX, normalY, lineInterx, lineIntery) && inpolygon(normalX, normalY, perpenLinex, perpenLiney)
                            startPoint = beacon;
                            plot(normalX, normalY, 'ro'); hold on;
                            err = 1;
                        else
                            distNorm1 = sqrt((lineInterx(1) - normalX)^2+(lineIntery(1) - normalY)^2);
                            distNorm2 = sqrt((lineInterx(2) - normalX)^2+(lineIntery(2) - normalY)^2);
                            if distNorm1 > distNorm2
                                startPoint = [lineInterx(2) lineIntery(2)];
                                err = 0;
                            elseif distNorm1 < distNorm2
                                startPoint = [lineInterx(1) lineIntery(1)];
                                err = 0;
                            else
                                startPoint = beacon;
                                err = 1;
                            end
                        end
                    else
                        if pathTempX == 1
                            startPoint = beacon;
                            err = 0;
                        else
                            startPoint = beacon;
                            err = 0;
                        end
                    end
                end
                if err == 0
                    pathTempX(numNodes*2) = beacon(1);
                    pathTempY(numNodes*2) = beacon(2);
                    pathTempX = pathTempX(pathTempX ~= 0);
                    pathTempY = pathTempY(pathTempY ~= 0);
                    pathBAT = [pathTempX pathTempY];
                else
                    pathBAT = [1 1];
                    disp('There is no B.A.T. for this polygon.')
                end
                start = uicontrol('Style', 'pushbutton', 'String', 'Start!', 'Position', [20 400 100 20], 'Callback', {@startPath, pathBAT}); 
        end
    end
    
    function resetSim(source, event)
        cla reset;
        set(gca, 'xtickLabel', [], 'ytickLabel', [], 'xtick', [], 'ytick', []);
    end

    function startPath(source, event, pathType)
        [row, col] = size(pathType);
        if col ~= 2
            highlight(p, pathType, 'EdgeColor', 'r', 'NodeColor', 'r', 'LineWidth', 3);
        else
            numRows = size(pathType, 1);
            for i = 1 : numRows
                if (i+1) <= numRows
                    linex = [pathType(i,1) pathType(i+1,1)];
                    liney = [pathType(i,2) pathType(i+1,2)];
                    plot(linex, liney, 'g', 'LineWidth', 3); hold on;
                end
            end
            hold off;
            highlight(p, pointNode, 'NodeColor', 'g', 'MarkerSize', 10);
            highlight(p, beaconNode, 'NodeColor', 'g', 'MarkerSize', 13);
        end
    end

    f.Visible = 'on'; %make entire figure visible
end
