--
-- util.lua
--


function isEmpty(argv)
	return (argv == nil or argv == '')
end

function notEmpty(argv)
	return (argv ~= nil and argv ~= '')
end
