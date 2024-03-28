function s = myXml2Struct(node)
    % Initialize an empty struct
    s = struct();
    
    % Check if node is an element node
    if node.getNodeType == node.ELEMENT_NODE
        childNodes = node.getChildNodes;
        numChildNodes = childNodes.getLength;
        
        textContent = ''; % Variable to capture text content
        
        for i = 0:numChildNodes-1
            childNode = childNodes.item(i);
            if childNode.getNodeType == childNode.ELEMENT_NODE
                childTagName = char(childNode.getTagName);
                
                % Recursive call for child nodes
                childStruct = myXml2Struct(childNode);
                
                % Handle multiple elements with the same tag name
                if isfield(s, childTagName)
                    if ~iscell(s.(childTagName))
                        s.(childTagName) = {s.(childTagName)};
                    end
                    s.(childTagName){end+1} = childStruct;
                else
                    s.(childTagName) = childStruct;
                end
            elseif childNode.getNodeType == childNode.TEXT_NODE
                % Accumulate text content from child text nodes
                textContent = [textContent char(childNode.getData().trim())];
            end
        end
        
        % Check and assign text content to 'Text' field or convert to double if appropriate
        if ~isempty(textContent)
            numValue = str2double(textContent);
            if isnan(numValue)
                s.Text = textContent; % Keep as text if not a number
            else
                s.Value = numValue; % Convert to double if it's numeric
            end
        end
        
        % Process attributes
        if node.hasAttributes
            attributes = node.getAttributes;
            numAttributes = attributes.getLength;
            for j = 0:numAttributes-1
                attribute = attributes.item(j);
                attrName = char(attribute.getName);
                attrValue = char(attribute.getValue);
                s.(['Attr_', attrName]) = attrValue;
            end
        end
    end
end
