require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  let(:user) { User.create!(
    email: 'test@example.com',
    password: 'password123',
    first_name: 'Test',
    last_name: 'User',
    country: "USA"
  )}
  
  let(:category) { Category.create!(name: 'Web Development') }
  
  let(:base_valid_attributes) { 
    {
      title: 'Senior Ruby Developer',
      description: 'We need an experienced Ruby developer for a 6-month project.',
      budget: 8500.50,
      category_id: category.id,
      skills: ['Ruby', 'Rails', 'PostgreSQL'],
      complexity: 'medium'
    }
  }

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Job" do
        expect {
          post :create, params: { job: base_valid_attributes }
        }.to change(Job, :count).by(1)
      end

      it "associates the job with the current user" do
        post :create, params: { job: base_valid_attributes }
        expect(assigns(:job).user).to eq(user)
      end

      it "redirects to the created job" do
        post :create, params: { job: base_valid_attributes }
        expect(response).to redirect_to(assigns(:job))
      end
    end

    context "with invalid parameters" do
      context "when title is blank" do
        let(:attributes) { base_valid_attributes.merge(title: '') }
        
        before { post :create, params: { job: attributes } }
        
        it "doesn't create a job" do
          expect { post :create, params: { job: attributes } }
            .not_to change(Job, :count)
        end
        
        it "has title error" do
            expect(assigns(:job).errors.full_messages).to contain_exactly("Title can't be blank")
        end
        
      end

      context "when budget is negative" do
        let(:attributes) { base_valid_attributes.merge(budget: -100) }
        
        before { post :create, params: { job: attributes } }
        
        it "doesn't create a job" do
          expect { post :create, params: { job: attributes } }
            .not_to change(Job, :count)
        end
        
        it "has budget error" do
            expect(assigns(:job).errors.full_messages).to contain_exactly("must be greater than or equal to 0")
        end
        
      end

      context "when category is missing" do
        let(:attributes) { base_valid_attributes.merge(category_id: nil) }
        
        before { post :create, params: { job: attributes } }
        
        it "doesn't create a job" do
          expect { post :create, params: { job: attributes } }
            .not_to change(Job, :count)
        end
        
        it "has category error" do
            expect(assigns(:job).errors.full_messages).to contain_exactly("must exist")
        end
        

      end

      context "when skills are empty" do
        let(:attributes) { base_valid_attributes.merge(skills: []) }
        
        before { post :create, params: { job: attributes } }
        
        it "doesn't create a job" do
          expect { post :create, params: { job: attributes } }
            .not_to change(Job, :count)
        end
        
        it "has skills error" do
            expect(assigns(:job).errors.full_messages).to contain_exactly("can't be blank")
        end
        

      end

      context "when complexity is invalid" do
        let(:attributes) { base_valid_attributes.merge(complexity: "invalid") }
        
        before { post :create, params: { job: attributes } }
        
        it "doesn't create a job" do
          expect { post :create, params: { job: attributes } }
            .not_to change(Job, :count)
        end
        
        it "has complexity error" do
            expect(assigns(:job).errors.full_messages).to contain_exactly("is not included in the list")
        end
        
      end
    end

    context "with skills as array of strings" do
        let(:attributes) { base_valid_attributes.merge(skills: ['Ruby', 'Rails', 'RSpec']) }
      
        it "saves the skills array correctly" do
          post :create, params: { job: attributes }
      
          expect(assigns(:job).skills).to eq(['Ruby', 'Rails', 'RSpec'])
          expect(assigns(:job)).to be_persisted
        end
      end
      
  end
end