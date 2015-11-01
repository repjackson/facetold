@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'




Meteor.methods
    updatelocation: (docid, result)->
        addresstags = (component.long_name for component in result.address_components)
        #console.log addresstags

        doc = Docs.findOne docid
        tagswithoutaddress = _.difference(doc.tags, doc.addresstags)
        tagswithnew = _.union(tagswithoutaddress, addresstags)

        Docs.update docid,
            $set:
                tags: tagswithnew
                locationob: result
                addresstags: addresstags
