package turn.message;

private typedef AttributeData = turn.message.attribute.Data;

typedef Data = {
    type: MessageType,
    transactionId: TransactionId,
    attributes: Array<AttributeData>
}