# Why this Framework?

## Comparison to other frameworks
Of course, the question to ask yourself is always: *"Out of all the frameworks in the world, why use this one?"* And the question is justified. There are a lot of other very good frameworks in the wild, such as [Kevin O'Hara's Lightweight Trigger Framework](https://github.com/kevinohara80/sfdc-trigger-framework) (of which I actually recommend [This fork](https://github.com/timbarsotti/sfdc-trigger-framework)), or the [fflib SObject Domain Pattern](https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectDomain.cls). Even most recently, the [Apex Trigger Actions Framework](https://github.com/mitchspano/apex-trigger-actions-framework) has made a splash in the scene - And it's going to be really interesting to see where it leads us.

However, with the exception of the Kevin O'Hara Framework, I think that these frameworks have a pretty high barrier to entry and are often dependent on the metadata being monolithic. With the exception of the Trigger Actions Framework, there is a strict requirement for the Trigger Handler to be present in the same package as the Trigger Handler. These are two things that we try to alleviate with our framework.

## Aims

The aim of the SFDX Trigger Factory we use at mindsquare is to **streamline** the most common actions that a developer does and **enforce clean style** by making specific methods for each trigger context. It's also **scalable**, which is to say that it is easy to implement a very simple Trigger Handler containing only basic business logic, but it's just as well possible to scale with a lot of different modules, functions, etc, given that separation of concerns is upheld.

## Streamlining
By streamlining, I am referring to the "**Cache - Process - Commit**" approach mentioned in the description of the repo. Each of these processes is supposed to be supported by one of the streams offered by the framework. 

### Caching
By calling either `bulkBefore()` or `bulkAfter()` we are able to prepare data by checking conditions on the records in our Trigger Context. These methods are supposed to be used primarily for storing data in Maps or Lists for retrieval later on in the trigger.

Alternatively, the two methods can also house bulk logic. This can be useful for grandfathering in old trigger methods into the new framework, or if your trigger is really barebones to start with.

### Processing
Processing happens on a per-record basis. This means that the following methods:

* `beforeInsert`
* `afterInsert`
* `beforeUpdate`
* `afterUpdate`
* `beforeDelete`
* `afterDelete`
* `afterUndelete`

are called separately **for each record**. With this in mind all bulkification is taken out of your hands here - you only need to worry about creating business logic for a single record. Additionally, it's easy to selectively add an Error message to a single record in a Trigger Context.

This style also enforces that we **absolutely do not use SOQL or DML** in these methods. Instead we add records into collections that should later be updated / inserted / deleted.

### Commit
`andFinally()` is called at the end of both the BEFORE context, as well as at the end of the AFTER context. In theory, `andFinally()` should also not contain any business logic, but instead focus on *committing what we have edited and created to the Database*. For this you can leverage the *[collections already offered by the Framework](features.md#store-database-operations-directly-in-your-handler)*, or you can use your own, if you decide that you need a slightly different or more sophisticated structure.