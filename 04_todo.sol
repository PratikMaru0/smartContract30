// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.13;

// What this smart contract do :- 
// Todo List ??
// - add tasks 
// - fetch the tasks
// - Remove on the completion

contract todo{
    address public owner;
    uint public taskNo;
    mapping(uint => string) public tasks;
    mapping(uint => bool) public completedTask;
    event taskAdded(string task);
    event taskCompleted(string task);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not owner");
        _;
    }
    

    // using calldata instead of memory becoz it will save gas.
    function addtask(string calldata _task, uint _taskNo) public onlyOwner {
        taskNo = _taskNo;
        tasks[taskNo] = _task;
        completedTask[taskNo] = false;
        emit taskAdded(_task);
    }

    function completeTask(uint _taskNo) public onlyOwner{
        require(!completedTask[_taskNo],"Task is already completed!");
        taskNo = _taskNo;
        completedTask[taskNo] = true;
        string memory task_ = tasks[taskNo];
        emit taskCompleted(task_);
    }

    function getTask(uint _taskNo) public view returns(string memory task){
        return tasks[_taskNo];
    }
}

// There is one more way to write this contract let see....

contract todo2{

    // Making a todostruct with the required dataset.
    struct Todo {
        string task;
        bool completed;
    }

    // Declaring events
    event taskAdded(string task);
    event taskCompleted(string task);
    event updateTask(uint index, string task);

    // This array consists of multple todo of user defined data type Todo
    Todo[] public todos;

    // Function to create todo
    function create(string calldata _task) external {
        todos.push(Todo({
            task: _task,
            completed: false
        }));
        emit taskAdded(_task);
    }

    // Function to mark todo complete
    function complete(uint _index) external {
        require(_index < todos.length,"This index number is not present");
        require(!todos[_index].completed,"Task is already completed");
        
        Todo storage todo = todos[_index];
        todo.completed = true;
        emit taskCompleted(todo.task);
    }

    // Function to update the existing task.
    function update(uint _index, string calldata _task) external{
        Todo storage curr = todos[_index];
        require(curr.completed == false,"Task is already completed");
        todos[_index].task = _task;
        emit updateTask(_index,_task);
    }

    // Function to get the task details like :- task and status 
    function getTask(uint _index) external view returns(string memory , bool){
        Todo memory todo = todos[_index];
        return (todo.task,todo.completed);
    } 
}
