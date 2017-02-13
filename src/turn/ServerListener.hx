package turn;

typedef ServerListener = {
    onAllocateRequest: turn.message.Data -> (Null<js.Error> -> turn.message.Data -> Void) -> Void,
    onBindingRequest: turn.message.Data -> (Null<js.Error> -> turn.message.Data -> Void) -> Void,
}