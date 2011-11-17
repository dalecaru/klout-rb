require 'spec_helper'

describe Klout::Client do
  before do
    @query = {:key => ""}
  end

  describe "errors" do
    context "no users found" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:body => fixture("no_users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should raise an error if users are not found" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error, "No users")
      end
    end

    context "invalid key" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:status => 403, :body => "<h1> 403 Developer Inactive </h1>", :headers => {:content_type => "application/xml; charset=utf-8"})
      end

      it "should raise an error if the key is invalid" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error::Forbidden)
      end
    end

    context "internal server error" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:status => 500)
      end

      it "should raise an error if there is a server error in klout" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error::InternalServerError)
      end
    end

    context "service unavailable" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:status => 503)
      end

      it "should raise an error if the service is unavailable" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error::ServiceUnavailable)
      end
    end

    context "gateway timeout" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:status => 504)
      end

      it "should raise an error if a gateway timeout is received" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error::GatewayTimeout)
      end
    end

    context "non sucessful response" do
      before do
        stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
          to_return(:status => 502)
      end

      it "should raise an error for non 200 response codes" do
        expect { Klout::Client.score("damiancaruso") }.to raise_error(Klout::Error)
      end
    end
  end

  describe ".score" do
    before do
      stub_get("/1/klout.json").with(:query => @query.merge({:users => "damiancaruso"})).
        to_return(:body => fixture("klout.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get a the klout score object for the given users" do
      users = Klout::Client.score("damiancaruso")
      users.first.twitter_screen_name.should_not be_nil
      users.first.kscore.should be_kind_of(Numeric)
    end
  end

  describe ".profile" do
    before do
      stub_get("/1/users/show.json").with(:query => @query.merge({:users => "damiancaruso"})).
        to_return(:body => fixture("users_show.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get a the klout user object for the given users" do
      users = Klout::Client.profile("damiancaruso")
      users.first.twitter_id.should_not be_nil
      users.first.twitter_screen_name.should_not be_nil
      users.first.score.kscore.should be_kind_of(Numeric)
      users.first.score.slope.should be_kind_of(Numeric)
      users.first.score.description.should_not be_nil
      users.first.score.kclass_id.should be_kind_of(Numeric)
      users.first.score.kclass.should_not be_nil
      users.first.score.kclass_description.should_not be_nil
      users.first.score.kscore_description.should_not be_nil
      users.first.score.network_score.should be_kind_of(Numeric)
      users.first.score.amplification_score.should be_kind_of(Numeric)
      users.first.score.true_reach.should be_kind_of(Numeric)
      users.first.score.delta_1day.should be_kind_of(Numeric)
      users.first.score.delta_5day.should be_kind_of(Numeric)
    end
  end

  describe ".topics" do
    before do
      stub_get("/1/users/topics.json").with(:query => @query.merge({:users => "damiancaruso"})).
        to_return(:body => fixture("users_topics.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get a the klout topic object for the given users" do
      users = Klout::Client.topics("damiancaruso")
      users.first.twitter_screen_name.should_not be_nil
      users.first.topics.should be_kind_of(Array)
    end
  end

  describe ".influenced_by" do
    before do
      stub_get("/1/soi/influenced_by.json").with(:query => @query.merge({:users => "damiancaruso"})).
        to_return(:body => fixture("soi_influenced_by.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get a the klout score object for the given users's influencers" do
      users = Klout::Client.influenced_by("damiancaruso")
      users.first.twitter_screen_name.should_not be_nil
      users.first.influencers.should be_kind_of(Array)
      users.first.influencers.first.twitter_screen_name.should_not be_nil
      users.first.influencers.first.kscore.should be_kind_of(Numeric)
    end
  end

  describe ".influencer_of" do
    before do
      stub_get("/1/soi/influencer_of.json").with(:query => @query.merge({:users => "damiancaruso"})).
        to_return(:body => fixture("soi_influencer_of.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get a the klout score object for the given users's influenceers" do
      users = Klout::Client.influencer_of("damiancaruso")
      users.first.twitter_screen_name.should_not be_nil
      users.first.influencees.should be_kind_of(Array)
      users.first.influencees.first.twitter_screen_name.should_not be_nil
      users.first.influencees.first.kscore.should be_kind_of(Numeric)
    end
  end
end
