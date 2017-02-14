package turn;

typedef AdapterCallback = Null<js.Error> -> turn.message.Data -> Void;

typedef Adapter = {
    onAllocateRequest: Request -> AdapterCallback -> Void,
    onBindingRequest: Request -> AdapterCallback -> Void,
}