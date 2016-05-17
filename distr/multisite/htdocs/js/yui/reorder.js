/*
 * yui-ext
 * Copyright(c) 2006, Jack Slocum.
 */

var TreeTest = function(){
    var Tree = YAHOO.ext.tree;
    return {
        init : function(){
            var tree = new Tree.TreePanel('tree-div', {
                animate: true, 
                loader: new Tree.TreeLoader({
                    dataUrl:'nodes.txt',
                    requestMethod: 'GET'
                }),
                enableDD: true,
                containerScroll: true
            });
            
            // set the root node
            var root = new Tree.AsyncTreeNode({
                text: 'yui-ext', 
                draggable: false, 
                id: 'source'
            });
            tree.setRootNode(root);
            
            // render the tree
            tree.render();
            
            // false for not recursive (the default), false to disable animation
            root.expand();
        }
    };
}();

//YAHOO.ext.EventManager.onDocumentReady(TreeTest.init, TreeTest, true);